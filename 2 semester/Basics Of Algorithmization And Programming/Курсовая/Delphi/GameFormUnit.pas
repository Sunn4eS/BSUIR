Unit GameFormUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.Pngimage,
    AlienUnit, GameOverUnit, PlayersListUnit;

Const
    ROCKET_BULLET = 0;
    ALIEN_BULLET = 1;
    START_LIVES = 3;
    ALL_ALIENS = 50;
    SHIFTR = 70;

Type

    Bullets = (RocketBullet, AlienBullet);
    TBulletArr = Array [0 .. 1] Of TImage;

    TSpaceInvadersForm = Class(TForm)
        RocketImage: TImage;
        BulletImage: TImage;
        BulletTimer: TTimer;
        MoveRocketTimer: TTimer;
        AlienTimer: TTimer;
        AlienBulletTimer: TTimer;
        ScorePaintBox: TPaintBox;
        PauseButtonImage: TImage;

        Procedure FormCreate(Sender: TObject);
        Procedure FormKeyDown(Sender: TObject; Var Key: Word;
          Shift: TShiftState);
        Procedure BulletTimerTimer(Sender: TObject);
        Procedure FormKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
        Procedure MoveRocketTimerTimer(Sender: TObject);
        Procedure FormPaint(Sender: TObject);
        Procedure AlienTimerTimer(Sender: TObject);
        Procedure AlienBulletTimerTimer(Sender: TObject);
        Procedure CreateForm(FormClass: TFormClass);
        Procedure ScorePaintBoxPaint(Sender: TObject);
        Procedure PauseButtonImageClick(Sender: TObject);
        Procedure DisableTimers();
        Procedure EnableTimers();
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);

    Private
        LeftPressed: Boolean;
        RightPressed: Boolean;
        Pressed: Boolean;
        Aliens: TAlien;
        AliensBullets: TAlienBullet;

        AlienBulletBitMap: TBitMap;
        AlienBitMap: TBitMap;
        BackGroundBitMap: TBitMap;
        BoomBitMap: TBitMap;
        BackAliens: TBitMap;
        RocketBoomBitMap: TBitMap;
        LifeBitMap: TBitMap;
    Public

    End;

Var
    SpaceInvadersForm: TSpaceInvadersForm;
    Bullet: TBulletArr;
    IsShoot: Boolean = False;
    IsMoving: Boolean = False;
    ShouldClose: Boolean = False;

    Score: Integer;
    Lives: Integer;
    IsStartOpen: Boolean = False;
    PlayersList: Player;
    PlayerInGame: Player;

Implementation

Uses
    ImageUnit, RocketUnit, CanvasUnit, PauseUnit, StartMenuUnit;

{$R *.dfm}

Procedure TSpaceInvadersForm.DisableTimers();
Begin
    AlienTimer.Enabled := False;
    BulletTimer.Enabled := False;
    AlienBulletTimer.Enabled := False;
    MoveRocketTimer.Enabled := False;
End;

Procedure TSpaceInvadersForm.EnableTimers();
Begin
    AlienTimer.Enabled := True;
    BulletTimer.Enabled := True;
    AlienBulletTimer.Enabled := True;
    MoveRocketTimer.Enabled := True;
End;

Procedure TSpaceInvadersForm.FormCloseQuery(Sender: TObject;
  Var CanClose: Boolean);
Var
    Confirmation: Integer;
Begin
    CanClose := True;

    DisableTimers();

End;

Procedure TSpaceInvadersForm.FormCreate(Sender: TObject);
Begin
    DisableTimers();
    If Not IsStartOpen Then
    Begin
        SpaceInvadersForm.Visible := False;
        CreateForm(TStartMenuForm);
        SpaceInvadersForm.Visible := True;

        If ShouldClose Then
        Begin
            Application.Terminate;
        End;

    End;

    DisableTimers();

    Bullet[ROCKET_BULLET] := TImage.Create(Self);
    Bullet[ALIEN_BULLET] := TImage.Create(Self);
    InitializeBullets(Bullet);

    SpawnRocket(RocketImage, SpaceInvadersForm);
    SetBackGround(BackGroundBitMap);

    BulletImage.Enabled := False;

    AlienBitMap := TBitmap.Create;
    BackAliens := TBitMap.Create;
    BoomBitMap := TBitmap.Create;
    RocketBoomBitMap := TBitmap.Create;
    LifeBitMap := TBitmap.Create;

    LoadBitMap(BackAliens, 'BackAliens');
    LoadBitMap(BoomBitMap, 'Boom');
    LoadBitMap(RocketBoomBitMap, 'RocketBoom');
    LoadBitMap(LifeBitMap, 'Heart');

    Pressed := False;

    Lives := 3;
    Score := 0;
    InitializeAlienBullets(AliensBullets);
    InitializeAliens(Aliens);
    SetAliensStartPos(Aliens);

    EnableTimers();

End;

Procedure TSpaceInvadersForm.FormKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    If Key = VK_ESCAPE Then
        PauseButtonImageClick(Self);
    If Not Pressed Then
    Begin
        IsPressed(Key, LeftPressed, RightPressed, Pressed);

    End;
    SpawnRocketBullet(BulletImage, RocketImage, Key, IsShoot, Bullet);

End;

Procedure TSpaceInvadersForm.FormKeyUp(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
    StopRocket(Key, LeftPressed, RightPressed, Pressed);
End;

Procedure TSpaceInvadersForm.FormPaint(Sender: TObject);
Begin
    Canvas.Draw(0, 0, BackGroundBitMap);
End;

Procedure TSpaceInvadersForm.MoveRocketTimerTimer(Sender: TObject);
Begin
    MoveRocket(RocketImage, SpaceInvadersForm, LeftPressed, RightPressed);
End;

Procedure TSpaceInvadersForm.PauseButtonImageClick(Sender: TObject);
Begin
    DisableTimers();
    CreateForm(TPauseForm);
End;

Procedure TSpaceInvadersForm.ScorePaintBoxPaint(Sender: TObject);

Begin
    With ScorePaintBox Do
    Begin
        Canvas.Font.Name := 'Vineta BT';
        Canvas.Brush.Color := ClBlack;
        Canvas.FillRect(ClientRect);

        Canvas.Font.Size := 25;
        Canvas.Font.Color := ClWhite;

        Canvas.TextOut(0, 0, 'Score:');
        Canvas.TextOut(300, 0, IntToStr(Score));
    End;
End;

Var
    Direction: Boolean = True;

Procedure TSpaceInvadersForm.AlienBulletTimerTimer(Sender: TObject);
Begin
    ShootAlienBullet(Aliens, AliensBullets);

End;

Procedure TSpaceInvadersForm.CreateForm(FormClass: TFormClass);
Var
    Form: TForm;
Begin
    Form := FormClass.Create(SpaceInvadersForm);
    Form.Icon := SpaceInvadersForm.Icon;
    Form.ShowModal;
End;

Procedure TSpaceInvadersForm.AlienTimerTimer(Sender: TObject);
Var
    PrevLives: Integer;
    I, J, K: Integer;

Begin
    RocketImage.Visible := True;
    PrevLives := Lives;

    Canvas.Draw(0, 0, BackGroundBitMap);
    MoveAliens(Aliens, SpaceInvadersForm.Left, SpaceInvadersForm.ClientWidth,
      RocketImage.Top, Direction);
    MoveAlienBullet(RocketImage, AliensBullets,
      SpaceInvadersForm.Height, Lives);

    ScorePaintBoxPaint(Self);

    For I := 0 To Lives - 1 Do
        Canvas.Draw(100 + I * ShiftR, 10, LifeBitMap);

    If CheckBorderOfRocket(Aliens, RocketImage) Then
        Lives := 0;

    If PrevLives <> Lives Then
    Begin
        RocketImage.Visible := False;
        Canvas.Draw(RocketImage.Left, RocketImage.Top, RocketBoomBitMap);
        For I := 0 To 4 Do
            For J := 0 To 9 Do
                If Aliens[I, J].Killed = False Then
                    Canvas.Draw(Aliens[I, J].PosX, Aliens[I, J].PosY,
                      Aliens[I, J].Image);

        For I := 0 To Lives - 1 Do
            Canvas.Draw(100 + I * ShiftR, 10, LifeBitMap);

        Sleep(500);

        If Lives = 0 Then
        Begin
            DisableTimers();
            CreateForm(TGameOverForm);
            IsStartOpen := False;
            FormCreate(Self);
        End;
    End;

    For I := 0 To High(AliensBullets) Do
        If AliensBullets[I].Visible Then
            Canvas.Draw(AliensBullets[I].PosX, AliensBullets[I].PosY,
              AliensBullets[I].Image);

    For I := 0 To 4 Do
        For J := 0 To 9 Do
            If Aliens[I, J].Killed = False Then
                Canvas.Draw(Aliens[I, J].PosX, Aliens[I, J].PosY,
                  Aliens[I, J].Image);
    RocketImage.Repaint;
    PauseButtonImage.Repaint;

End;

Procedure TSpaceInvadersForm.BulletTimerTimer(Sender: TObject);
Var
    CountOfkilled: Integer;
Begin
    // Передвижение снаряда пушки
    MoveRocketBullet(BulletImage, IsShoot);
    // Установка начального значения счётчкиа пораженных врагов
    CountOfkilled := 0;
    // Проходимся по всем врагам
    For Var I := 0 To 4 Do
        For Var J := 0 To 9 Do
        Begin
            // Поражен ли враг
            If Not Aliens[I, J].Killed Then
                // Проверка пересечения снаряда пушки и границ врага
                If CheckBulletCollision(Aliens[I, J], BulletImage) Then
                Begin
                    // Уничтожение врага
                    KillAlien(Aliens[I, J], BulletImage, IsShoot, Score);
                    // Отрисовка картинки взрыва
                    Canvas.Draw(Aliens[I, J].PosX, Aliens[I, J].PosY,
                      BoomBitMap);
                End;
            // Враг поражен
            If Aliens[I, J].Killed Then
            Begin
                // Увеличение счетчика пораженных врагов на один
                Inc(CountOfKilled);
            End;
        End;
    // Поражены ли все враги
    If CountOfkilled = ALL_ALIENS Then
    Begin
        // Перезапись данных всех врагов
        InitializeAliens(Aliens);
        // Установка начального положения для врагов
        SetAliensStartPos(Aliens);
    End;
End;

End.
