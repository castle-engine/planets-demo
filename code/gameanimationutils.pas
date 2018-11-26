{ Utilities to easily animate rotation around an orbit or own center. }
unit GameAnimationUtils;

interface

uses Classes,
  CastleVectors;

type
  { Animate movement around an orbit. }
  TOrbitAnimation = class(TComponent)
  strict private
    Angle, Speed, Radius: Single;
    Axis, InitialTranslation: TVector3;
  public
    { Set Radius, randomize the rest. }
    constructor Create(const AOwner: TComponent; const ARadius: Single); reintroduce;
    procedure Update(const SecondsPassed: Single);
    function Translation: TVector3;
  end;

  { Animate rotation around own center. }
  TRotationAnimation = class(TComponent)
  strict private
    Angle, Speed: Single;
    Axis: TVector3;
  public
    { Randomize everything. }
    constructor Create(AOwner: TComponent); override;
    procedure Update(const SecondsPassed: Single);
    { Current rotation, axis and angle
      (compatible with TCastleTransform.Rotation or TTransformNode.Rotation). }
    function Rotation: TVector4;
  end;

implementation

uses CastleUtils;

function RandomAxis: TVector3;
begin
  { Note: This is not a fair randomization (it's not uniform if you consider
    all possible 3D angles). And it doesn't try to secure from the (extremely
    rare...) case that we randomly choose zero vector.
    It's only "good enough" for this demo -- in practice it looks good. }
  Result := Vector3(Random * 2 - 1, Random * 2 - 1, Random * 2 - 1).Normalize;
end;

{ TOrbitAnimation ------------------------------------------------------------ }

constructor TOrbitAnimation.Create(const AOwner: TComponent; const ARadius: Single);
begin
  inherited Create(AOwner);
  Radius := ARadius;
  Axis := RandomAxis;
  InitialTranslation := AnyOrthogonalVector(Axis) * Radius;
  Speed := RandomFloatRange(0.5, 0.75);
  // leave Angle initialized to 0
end;

procedure TOrbitAnimation.Update(const SecondsPassed: Single);
begin
  Angle += Speed * SecondsPassed;
end;

function TOrbitAnimation.Translation: TVector3;
begin
  Result := RotatePointAroundAxisRad(Angle, InitialTranslation, Axis);
end;

{ TRotationAnimation --------------------------------------------------------- }

constructor TRotationAnimation.Create(AOwner: TComponent);
begin
  inherited;
  Axis := RandomAxis;
  Speed := RandomFloatRange(3, 6);
  // leave Angle initialized to 0
end;

procedure TRotationAnimation.Update(const SecondsPassed: Single);
begin
  Angle += Speed * SecondsPassed;
end;

function TRotationAnimation.Rotation: TVector4;
begin
  Result := Vector4(Axis, Angle);
end;

end.
