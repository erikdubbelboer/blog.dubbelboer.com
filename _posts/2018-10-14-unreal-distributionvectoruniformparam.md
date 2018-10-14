---
title: UE4 DistributionVectorUniformParam Particle Distribution
layout: post
keywords: unreal engine ue4 distribution vector particle uniform param
---

While creating weapon effects for our game I needed quite dynamic particle effects that look random but still depend on the range and splash range of the weapons.
Using Distribution Vector Param and dynamically setting the range of the particle effects works for some cases but doesn't work if you have multiple particles that need to have random values.
To fix this I created the missing Distribution Vector Uniform Param.

![Example parameters](/images/2018-10-14-example-distribution.png)

[DistributionVectorUniformParam.h](https://gist.github.com/erikdubbelboer/cd674cd29399bc9bddb9c9c8a6bd7886#file-distributionvectoruniformparam-h)
{% highlight cpp %}
#pragma once

#include "CoreMinimal.h"
#include "Distributions/DistributionVector.h"

#include "DistributionVectorUniformParam.generated.h"


UCLASS(collapsecategories, hidecategories = Object, editinlinenew)
class PROJECT_API UDistributionVectorUniformParam : public UDistributionVector
{
  GENERATED_UCLASS_BODY()


  UPROPERTY(EditAnywhere)
  FName MaxParameterName;

  UPROPERTY(EditAnywhere)
  FName MinParameterName;

  UPROPERTY(EditAnywhere)
  FVector DefaultMax;

  UPROPERTY(EditAnywhere)
  FVector DefaultMin;

  virtual FVector GetValue(float F = 0.f, UObject* Data = NULL, int32 LastExtreme = 0, struct FRandomStream* InRandomStream = NULL) const override;

  virtual bool CanBeBaked() const override { return false; }
  virtual bool IsPostLoadThreadSafe() const override { return true; };

public:
  UDistributionVectorUniformParam();

private:
  bool GetParamValue(UObject* Data, FName ParamName, FVector& OutVector) const;
};
{% endhighlight %}

[DistributionVectorUniformParam.cpp](https://gist.github.com/erikdubbelboer/cd674cd29399bc9bddb9c9c8a6bd7886#file-distributionvectoruniformparam-cpp)
{% highlight cpp %}
#include "DistributionVectorUniformParam.h"

#include "Particles/ParticleSystemComponent.h"


UDistributionVectorUniformParam::UDistributionVectorUniformParam(const FObjectInitializer& ObjectInitializer)
  : Super(ObjectInitializer)
{
}

FVector UDistributionVectorUniformParam::GetValue(float F, UObject* Data, int32 Extreme, struct FRandomStream* InRandomStream) const
{
  FVector LocalMax = DefaultMax;
  FVector LocalMin = DefaultMin;

  FVector ParamMax;
  bool bFoundParam = GetParamValue(Data, MaxParameterName, ParamMax);
  if (bFoundParam)
  {
    LocalMax = ParamMax;
  }

  FVector ParamMin;
  bFoundParam = GetParamValue(Data, MinParameterName, ParamMin);
  if (bFoundParam)
  {
    LocalMin = ParamMin;
  }

  float fX = LocalMin.X + (LocalMax.X - LocalMin.X) * DIST_GET_RANDOM_VALUE(InRandomStream);
  float fY = LocalMin.Y + (LocalMax.Y - LocalMin.Y) * DIST_GET_RANDOM_VALUE(InRandomStream);
  float fZ = LocalMin.Z + (LocalMax.Z - LocalMin.Z) * DIST_GET_RANDOM_VALUE(InRandomStream);

  return FVector(fX, fY, fZ);
}

bool UDistributionVectorUniformParam::GetParamValue(UObject* Data, FName ParamName, FVector& OutVector) const
{
  bool bFoundParam = false;

  UParticleSystemComponent* ParticleComp = Cast<UParticleSystemComponent>(Data);
  if (ParticleComp)
  {
    bFoundParam = ParticleComp->GetAnyVectorParameter(ParamName, OutVector);
  }
  return bFoundParam;
}
{% endhighlight %}
