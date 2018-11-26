{ Game initialization and logic. }
unit GameInitialize;

interface

implementation

uses SysUtils,
  CastleWindow, CastleScene, CastleLog, CastleColors, CastleControls,
  CastleUIControls, CastleApplicationProperties, CastleVectors,
  X3DNodes,
  GameAnimationUtils;

var
  Window: TCastleWindow;
  LabelFps: TCastleLabel;
  SceneEarth, SceneMoon, SceneSatellite: TCastleScene;
  LightTransform: TTransformNode;

  { Animation parameters. }
  LightOrbit, MoonOrbit, SatelliteOrbit: TOrbitAnimation;
  MoonRotation, SatelliteRotation: TRotationAnimation;

{ routines ------------------------------------------------------------------- }

{ Set translations and rotations of all animated items. }
procedure UpdateTransformations;
begin
  LightTransform.Translation := LightOrbit.Translation;
  SceneMoon.Translation := MoonOrbit.Translation;
  SceneSatellite.Translation := SatelliteOrbit.Translation;
  SceneMoon.Rotation := MoonRotation.Rotation;
  SceneSatellite.Rotation := SatelliteRotation.Rotation;
end;

procedure WindowUpdate(Container: TUIContainer);
var
  SecondsPassed: Single;
begin
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  SecondsPassed := Container.Fps.SecondsPassed;

  LightOrbit.Update(SecondsPassed);
  MoonOrbit.Update(SecondsPassed);
  SatelliteOrbit.Update(SecondsPassed);
  MoonRotation.Update(SecondsPassed);
  SatelliteRotation.Update(SecondsPassed);

  UpdateTransformations;
end;

{ One-time initialization of resources. }
procedure ApplicationInitialize;
begin
  { Assign Window callbacks. }
  Window.OnUpdate := @WindowUpdate;

  { Show a label with frames per second information. }
  LabelFps := TCastleLabel.Create(Application);
  LabelFps.Anchor(vpTop, -10);
  LabelFps.Anchor(hpRight, -10);
  LabelFps.Color := Yellow;
  Window.Controls.InsertFront(LabelFps);

  { Load earth and light. }
  SceneEarth := TCastleScene.Create(Application);
  SceneEarth.Load('castle-data:/earth_and_light.x3d');
  SceneEarth.Attributes.PhongShading := true;
  Window.SceneManager.Items.Add(SceneEarth);
  { Thanks to ProcessEvents you can animate stuff within, like light }
  SceneEarth.ProcessEvents := true;
  { Set as MainScene (determines default camera, lights that shine on all other scenes) }
  Window.SceneManager.MainScene := SceneEarth;
  { Get Sun transformation }
  LightTransform := SceneEarth.Node('Sun_TRANSFORM') as TTransformNode;

  { Load moon. }
  SceneMoon := TCastleScene.Create(Application);
  SceneMoon.Load('castle-data:/moon.x3d');
  Window.SceneManager.Items.Add(SceneMoon);

  { Load satellite. }
  SceneSatellite := TCastleScene.Create(Application);
  SceneSatellite.Load('castle-data:/satellite.x3d');
  Window.SceneManager.Items.Add(SceneSatellite);

  { Initialize animations. }
  LightOrbit := TOrbitAnimation.Create(Application, 7);
  MoonOrbit := TOrbitAnimation.Create(Application, 3);
  SatelliteOrbit := TOrbitAnimation.Create(Application, 4);
  MoonRotation := TRotationAnimation.Create(Application);
  SatelliteRotation := TRotationAnimation.Create(Application);

  UpdateTransformations;
end;

initialization
  { Set ApplicationName early, as our log uses it. }
  ApplicationProperties.ApplicationName := 'planets_demo';

  { Initialize Application.OnInitialize. }
  Application.OnInitialize := @ApplicationInitialize;

  { Create and assign Application.MainWindow. }
  Window := TCastleWindow.Create(Application);
  Application.MainWindow := Window;
end.
