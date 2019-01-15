---
published: true
title: PHP shell_exec with a timeout
layout: post
keywords: php exec timeout
---

This function allows you to execute another process but with a timeout on how long it's allowed to run.

Update *2018-01-15*
-------------------

Made the function actually work by changing stderr to non-blocking as well. Before it never worked :) Thanks to danny23 for pointing this out.

Update *2012-08-28* 
-------------------

Changed the code to use exec inside `proc_open`. This causes `proc_terminate` to work correctly. One disadvantage is that you need to use the full path of the executable you want to run.

Also setting environment variables using VARIABLE=something before the command won't work anymore. This can be fixed by calling `putenv` before calling the function.

The function now throws an exception in case of an error.


{% highlight php %}
<?

/**
 * Execute a command and return it's output. Either wait until the command exits or the timeout has expired.
 *
 * @param string $cmd     Command to execute.
 * @param number $timeout Timeout in seconds.
 * @return string Output of the command.
 * @throws \Exception
 */
function exec_timeout($cmd, $timeout) {
  // File descriptors passed to the process.
  $descriptors = array(
    0 => array('pipe', 'r'),  // stdin
    1 => array('pipe', 'w'),  // stdout
    2 => array('pipe', 'w')   // stderr
  );

  // Start the process.
  $process = proc_open('exec ' . $cmd, $descriptors, $pipes);

  if (!is_resource($process)) {
    throw new \Exception('Could not execute process');
  }

  // Set the stdout stream to non-blocking.
  stream_set_blocking($pipes[1], 0);

  // Set the stderr stream to non-blocking.
  stream_set_blocking($pipes[2], 0);

  // Turn the timeout into microseconds.
  $timeout = $timeout * 1000000;

  // Output buffer.
  $buffer = '';

  // While we have time to wait.
  while ($timeout > 0) {
    $start = microtime(true);

    // Wait until we have output or the timer expired.
    $read  = array($pipes[1]);
    $other = array();
    stream_select($read, $other, $other, 0, $timeout);

    // Get the status of the process.
    // Do this before we read from the stream,
    // this way we can't lose the last bit of output if the process dies between these functions.
    $status = proc_get_status($process);

    // Read the contents from the buffer.
    // This function will always return immediately as the stream is non-blocking.
    $buffer .= stream_get_contents($pipes[1]);

    if (!$status['running']) {
      // Break from this loop if the process exited before the timeout.
      break;
    }

    // Subtract the number of microseconds that we waited.
    $timeout -= (microtime(true) - $start) * 1000000;
  }

  // Check if there were any errors.
  $errors = stream_get_contents($pipes[2]);

  if (!empty($errors)) {
    throw new \Exception($errors);
  }

  // Kill the process in case the timeout expired and it's still running.
  // If the process already exited this won't do anything.
  proc_terminate($process, 9);

  // Close all streams.
  fclose($pipes[0]);
  fclose($pipes[1]);
  fclose($pipes[2]);

  proc_close($process);

  return $buffer;
}
{% endhighlight %}


The function will not work on windows due to limitations in windows and PHP:

`Use of stream_select() on file descriptors returned by proc_open() will fail and return FALSE under Windows.`

