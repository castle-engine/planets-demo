{ Game initialization and logic. }
unit GameInitialize;

interface

implementation

uses SysUtils,
  CastleWindow, CastleScene, CastleLog, CastleColors, CastleControls,
  CastleUIControls, CastleApplicationProperties, CastleVectors,
  X3DNodes, CastleBoxes,
  GameAnimationUtils;

var
  Window: TCastleWindow;
  LabelFps: TCastleLabel;
  SceneCameraAndLight, SceneEarth, SceneMoon, SceneSatellite: TCastleScene;
  LightTransform, LightSphereTransform: TTransformNode;

  { Animation parameters. }
  LightOrbit, MoonOrbit, SatelliteOrbit: TOrbitAnimation;
  EarthRotation, MoonRotation, SatelliteRotation: TRotationAnimation;

{ routines ------------------------------------------------------------------- }

{ Set translations and rotations of all animated items. }
procedure UpdateTransformations;
begin
  { Both LightTransform and LightSphereTransform have the same Translation. }
  LightTransform.Translation := LightOrbit.Translation;
  LightSphereTransform.Translation := LightOrbit.Translation;

  SceneMoon.Translation := MoonOrbit.Translation;
  SceneSatellite.Translation := SatelliteOrbit.Translation;

  SceneEarth.Rotation := EarthRotation.Rotation;
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
  EarthRotation.Update(SecondsPassed);
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

  { Load camera and light. }
  SceneCameraAndLight := TCastleScene.Create(Application);
  SceneCameraAndLight.Load('castle-data:/camera_and_light.x3d');
  Window.SceneManager.Items.Add(SceneCameraAndLight);
  { Thanks to ProcessEvents you can animate stuff within, like light. }
  SceneCameraAndLight.ProcessEvents := true;
  { Set as MainScene (determines default camera, lights that shine on all other scenes) }
  Window.SceneManager.MainScene := SceneCameraAndLight;
  { Find named Transform nodes in the camera_and_light.x3d  }
  LightTransform := SceneCameraAndLight.Node('Sun_TRANSFORM') as TTransformNode;
  LightSphereTransform := SceneCameraAndLight.Node('SunSphere_TRANSFORM') as TTransformNode;

  { Load earth. }
  SceneEarth := TCastleScene.Create(Application);
  SceneEarth.Load('castle-data:/earth.x3d');
  Window.SceneManager.Items.Add(SceneEarth);

  { Load moon. }
  SceneMoon := TCastleScene.Create(Application);
  SceneMoon.Load('castle-data:/moon.x3d');
  Window.SceneManager.Items.Add(SceneMoon);

  { Load satellite. }
  SceneSatellite := TCastleScene.Create(Application);
  SceneSatellite.Load('castle-data:/satellite.x3d');
  Window.SceneManager.Items.Add(SceneSatellite);

  { Make rotations made by ExamineCamera nice.
    Otherwise ExamineCamera pivot of rotations would be calculated based
    on current bounding boxes at start, the camera doesn't know
    that it will all be animated and the center should be in (0,0,0). }
  Window.SceneManager.ExamineCamera.ModelBox := Box3D(
    Vector3(-10, -10, -10),
    Vector3( 10,  10,  10)
  );

  { Initialize animations. }
  LightOrbit := TOrbitAnimation.Create(Application, 4);
  MoonOrbit := TOrbitAnimation.Create(Application, 2.5);
  SatelliteOrbit := TOrbitAnimation.Create(Application, 1.5);
  EarthRotation := TRotationAnimation.Create(Application, 0.2);
  MoonRotation := TRotationAnimation.Create(Application, 0.8);
  SatelliteRotation := TRotationAnimation.Create(Application, 1);

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
