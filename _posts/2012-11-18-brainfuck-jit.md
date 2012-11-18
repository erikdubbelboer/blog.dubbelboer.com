---
published: true
title: Brainfuck JIT
layout: post
keywords: brainfuck jit lightning compile
---

[Brainfuck](http://en.wikipedia.org/wiki/Brainfuck) is an esoteric programming language with a very minimal amount of instructions.
This makes it an easy candidate to write interpreters and compilers for. As simple exercise I have written brainfuck interpreters in many languages. This time I tried a different approach. I have written a program to compile brainfuck to native instructions and then execute them.

I'm using [GNU lightning](http://www.gnu.org/software/lightning/manual/lightning.html) for the code generation. Lightning provides a portable, fast and easily retargetable dynamic code generation system. Lightning uses simple macro's to generate instructions, it doesn't do any optimizations.

Before generating instructions the program performs some minor optimizations:

* Multiple occurrences of > < + and - are combined into a single instruction. Also results in much cleaner assembly.
* \] does it's own conditional jump instead of jumping to the \[ and letting it take care of the condition.

More optimizations could be performed but I'll save this for a later time.

[brainfuck.c](https://github.com/ErikDubbelboer/brainfuck-jit/blob/master/brainfuck.c)
--------------------------------------------------------------------------------------

{% highlight c %}
#include <stdio.h>   /* printf(), fprintf() */
#include <string.h>  /* memset() */
#include <lightning.h>

/* Max nesting of [] */
static const int maxLoopDepth = 32;

/* The code buffer can't be stack allocated.
   I haven't checked why but I guess the stack can't
   be made executable. */
static jit_insn codeBuffer[1024*64]; /* This is the max number of instructions. */
static int      dataBuffer[30000];

/* Return the number of times *c is repeated.
   On return *c will contain the next character. */
int opCount(FILE* fp, int* c) {
  int n  = 1;  /* Seen it at least 1 time. */
  int cr = *c;

  while ((*c = fgetc(fp)) != EOF) {
    /* Skip invalid characters. */
    if ((*c == '>') ||
        (*c == '<') ||
        (*c == '+') ||
        (*c == '-') ||
        (*c == '.') ||
        (*c == ',') ||
        (*c == '[') ||
        (*c == ']')) {
      if (*c == cr) {
        ++n;
      } else {
        return n;
      }
    }
  }

  return n;
}

int main(int argc, char** argv) {
  if (argc < 2) {
    printf("Usage: %s [infile]\n", argv[0]);
    return 0;
  }

  FILE* fp = fopen(argv[1], "r");

  if (!fp) {
    fprintf(stderr, "Error: could not open %s\n", argv[1]);
    return 1;
  }

  memset(dataBuffer, 0, sizeof(dataBuffer));

  /* We use these as a simple stack to keep track of the loops. */
  jit_insn* loopStart[maxLoopDepth];
  jit_insn* loopEnd[maxLoopDepth];
  int loop = -1;

  void (*code)();
  /* Writing: code = (void (*)())jit_set_ip(codeBuffer).vptr;
     would seem more natural, but the C99 standard leaves
     casting from "void *" to a function pointer undefined.
     The assignment used below is the POSIX.1-2003 (Technical
     Corrigendum 1) workaround. */
  *(void **)(&code) = jit_set_ip(codeBuffer).vptr;

  /* Save the start of the code buffer. */
  char* start = jit_get_ip().ptr;

  /* Set up our stack frame and set V0 to our data buffer.
     Lightning guarantees that the V* registers won't be overwritten
     during function calls. We will use V0 to point to the current
     location in our data buffer.
     R1 will be used as general purpose register to perform operations on. */
  jit_prolog(0);
  jit_movi_p(JIT_V0, dataBuffer);

  int n;
  int c = fgetc(fp);
  do {
    if (jit_get_ip().ptr > (char*)(codeBuffer + sizeof(codeBuffer))) {
      fprintf(stderr, "Error: the program is to big!\n");
      return 4;
    }

    switch (c) {
      case '>': {
        /* We can't write jit_addi_i(JIT_V0, JIT_V0, opCount(fp, &c))
           because the jit_addi_i() macro evaluates it's arguments
           multiple times. */
        n = opCount(fp, &c);
        jit_addi_i(JIT_V0, JIT_V0, n); /* V0 += n */
        continue;
      }

      case '<': {
        n = opCount(fp, &c);
        jit_subi_i(JIT_V0, JIT_V0, n); /* V0 -= n */
        continue;
      }

      case '+': {
        n = opCount(fp, &c);

        jit_ldr_c(JIT_R1, JIT_V0);     /* R1   =  [V0] */
        jit_addi_i(JIT_R1, JIT_R1, n); /* R1   += n    */
        jit_str_c(JIT_V0, JIT_R1);     /* [V0] =  R1   */
        continue;
      }

      case '-': {
        n = opCount(fp, &c);

        jit_ldr_c(JIT_R1, JIT_V0);     /* R1   =  [V0] */
        jit_subi_i(JIT_R1, JIT_R1, n); /* R1   -= n    */
        jit_str_c(JIT_V0, JIT_R1);     /* [V0] =  R1   */
        continue;
      }

      case '.': {
        jit_ldr_c(JIT_R1, JIT_V0); /* R1 = [V0] */
        jit_prepare_i(1);
        jit_pusharg_i(JIT_R1);
        jit_finish(putchar);       /* putchar(R1) */
        break;
      }

      case ',': {
        jit_prepare(0);
        jit_finish(getchar);
        jit_retval_c(JIT_R1);      /* R1   = getchar() */
        jit_str_c(JIT_V0, JIT_R1); /* [V0] = R1        */
        break;
      }

      case '[': {
        ++loop;

        if (loop >= maxLoopDepth) {
          fprintf(stderr, "Error: nesting level to deep (max %d)!\n", maxLoopDepth);
          return 2;
        }

        jit_ldr_c(JIT_R1, JIT_V0); /* R1 = [V0] */

        /* if (R1 == 0) jump to the ] (which is unknown at this point) 
           We save the instruction location to patch it when we reach the ] */
        loopEnd[loop] = jit_beqi_i(jit_forward(), JIT_R1, 0); 

        /* Save this location so we can jump to it from the ] */
        loopStart[loop] = jit_get_label(); 
        break;
      }

      case ']': {
        if (loop < 0) {
          fprintf(stderr, "Error: invalid ] (missing [)\n");
          return 3;
        }

        jit_ldr_c(JIT_R1, JIT_V0); /* R1 = [V0] */

        /* if (R1 != 0) jump to the instruction after the [ */
        jit_bnei_i(loopStart[loop], JIT_R1, 0);

        /* Patch the conditional jump in the [ */
        jit_patch(loopEnd[loop]);

        --loop;
        break;
      }
    }
        
    c = fgetc(fp);
  } while (c != EOF);

  fclose(fp);

  if (loop > -1) {
    fprintf(stderr, "Error: %d unclosed loops!\n", loop + 1);
    return 5;
  }

  /* Unwind our stack frame. */
  jit_ret();

  /* Make sure the CPU hasn't cached any of the generated instructions. */
  jit_flush_code(start, jit_get_ip().ptr);


#if 0
  /* This code writes the generated instructions to a file
     so we can disassemble it using ndisasm. */
  int s = jit_get_ip().ptr - start;
  fp = fopen("code.bin", "wb");
  int i;
  for (i = 0; i < s; ++i) {
    fputc(start[i], fp);
  }
  fclose(fp);
#endif


  /* Execute the generated code. */
  code();

  return 0;
}
{% endhighlight %}

A simple program
----------------

The following is a simple program that will output "a\n".

{% highlight brainfuck %}
++++++++++  set cell #0 to 10
[           loop 10 times based on cell #0
>+++++++++  add 9 to cell #1
>+          add 1 to cell #2
<<
-           go back to cell #0 for the loop
]
>
+++++++     add 7 to cell #1 to increase it to 97
.           output cell #1 (97 = ascii a)
>
.           output cell #2 (10 = ascii newline)
{% endhighlight %}

Generated assembly
------------------

The above program generates the following assembly on my x86_64 Ubuntu machine.

The output was generated using `ndisasm -b 64 code.bin`.

`rbx` is used as the `V0` register from the C code. `r10` is used as `R1`.

{% highlight nasm %}
  ; Set up out stack frame.
  push rbx
  push r12
  push r13
  push r14
  push rbp
  mov rbp,rsp

  ; Set rbx to the location of our data array (dataBuffer in C).
  mov rbx,0x613100

  ; Add 10 to cell #0.
  movsx r10,byte [rbx]
  add r10d,byte +0xa
  mov [rbx],r10b

  ; Test if cell #0 is equal to 0.
  movsx r10,byte [rbx]
  test r10d,r10d
  jz .loopEnd
.loopStart:

  ; Add 1 to V0.
  add ebx,byte +0x1

  ; Add 9 to cell #1.
  movsx r10,byte [rbx]
  add r10d,byte +0x9
  mov [rbx],r10b

  ; Add 1 to V0.
  add ebx,byte +0x1

  ; Add 1 to cell #2.
  movsx r10,byte [rbx]
  add r10d,byte +0x1
  mov [rbx],r10b

  ; Subtract 2 from V0.
  add ebx,byte -0x2

  ; Subtract 1 from cell #0.
  movsx r10,byte [rbx]
  add r10d,byte -0x1
  mov [rbx],r10b

  ; Test if cell #0 is not equal to 0.
  movsx r10,byte [rbx]
  test r10d,r10d
  jnz .loopStart
.loopEnd:

  ; Add 1 to V0.
  add ebx,byte +0x1

  ; Add 7 to cell #1.
  movsx r10,byte [rbx]
  add r10d,byte +0x7
  mov [rbx],r10b

  ; Output cell #1.
  movsx r10,byte [rbx]
  mov rdi,r10
  mov al,0x0
  mov r12,0x4006e0 ; The location of the putchar() function.
  call r12

  ; Add 1 to V0.
  add ebx,byte +0x1

  ; Output cell #2.
  movsx r10,byte [rbx]
  mov rdi,r10
  mov al,0x0
  mov r12,0x4006e0
  call r12

  ; Unwind our stack frame.
  leave
  pop r14
  pop r13
  pop r12
  pop rbx
  ret
{% endhighlight %}

