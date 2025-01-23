Unit RocketUnit;

Interface

Uses
    VCL.Forms, Vcl.ExtCtrls, Winapi.Windows, GameFormUnit, AlienUnit,
    System.Types;

Const
    ROCKET_SPEED = 30;
    BULLET_SPEED = 30;

Procedure StopRocket(Var Key: Word; Var LeftPressed, RightPressed,
  Pressed: Boolean);
Procedure MoveRocket(Var RocketImage: TImage; Const Form: TForm;
  Var LeftPressed, RightPressed: Boolean);
Procedure IsPressed(Var Key: Word; Var LeftPressed, RightPressed,
  Pressed: Boolean);
Procedure SpawnRocket(Var RocketImage: TImage; Form: TForm);
Procedure SpawnRocketBullet(Bullet: TImage; RocketImage: TImage;
  Const Key: Word; Var IsShoot: Boolean; BulletType: TBulletArr);
Procedure MoveRocketBullet(Var BulletImage: TImage; Var IsShoot: Boolean);
Function CheckBulletCollision(Const Alien: TAlienRec;
  Const Bullet: TImage): Boolean;

Implementation

Function CheckBulletCollision(Const Alien: TAlienRec;
  Const Bullet: TImage): Boolean;
Var
    AlienHitBox: TRect;
    BulletHitBox: TRect;
Begin
    BulletHitBox := Rect(Bullet.Left, Bullet.Top, Bullet.Left + Bullet.Width,
      Bullet.Top + Bullet.Height);
    AlienHitBox := CalculateAlienHitBox(Alien);

    CheckBulletCollision := IntersectRect(BulletHitBox, AlienHitBox);
End;

Procedure MoveRocketBullet(Var BulletImage: TImage; Var IsShoot: Boolean);
Begin
    If IsShoot Then
    Begin
        BulletImage.Top := BulletImage.Top - BULLET_SPEED;
        If BulletImage.Top < 0 Then
        Begin
            IsShoot := False;
            BulletImage.Enabled := False;
            BulletImage.Visible := False;
        End;

    End;
End;

Procedure StopRocket(Var Key: Word; Var LeftPressed, RightPressed,
  Pressed: Boolean);
Begin
    If Key = VK_LEFT Then
    Begin
        LeftPressed := False;
        Pressed := False;
    End;
    If Key = VK_RIGHT Then
    Begin
        RightPressed := False;
        Pressed := False;
    End;
End;

Procedure SpawnRocket(Var RocketImage: TImage; Form: TForm);
Begin
    RocketImage.Left := Round((Form.Width - RocketImage.Picture.Width) / 2) - 7
      * RocketImage.Picture.Width;
    RocketImage.Top := Round((Form.Height - RocketImage.Picture.Height) / 1.2);
End;

Procedure SpawnRocketBullet(Bullet: TImage; RocketImage: TImage;
  Const Key: Word; Var IsShoot: Boolean; BulletType: TBulletArr);
Begin
    If Not IsShoot Then
    Begin
        If Key = VK_SPACE Then
        Begin
            Bullet.Picture := BulletType[ROCKET_BULLET].Picture;
            Bullet.Enabled := True;
            Bullet.Visible := True;
            Bullet.Left := RocketImage.Left + RocketImage.Picture.Width + 46;
            Bullet.Top := RocketImage.Top - 55;
            IsShoot := True;
        End;
    End;
End;

Procedure IsPressed(Var Key: Word; Var LeftPressed, RightPressed,
  Pressed: Boolean);
Begin

    Case Key Of
        VK_LEFT:
            Begin
                LeftPressed := True;
                RightPressed := False;
                Pressed := True;
            End;
        VK_RIGHT:
            Begin
                Pressed := True;
                LeftPressed := False;
                RightPressed := True;
            End;
    End;
End;

Procedure MoveRocket(Var RocketImage: TImage; Const Form: TForm;
  Var LeftPressed, RightPressed: Boolean);
Begin
    // Проверка на пересечение левой границы
    If (RocketImage.Left < 0) Then
        // Запрет движения влево
        LeftPressed := False;
    // Проверка на пересечение правой границы
    If (RocketImage.Left + RocketImage.Width > Form.ClientWidth) Then
        // Запрет движения вправо
        RightPressed := False;
    // Нажата ли стрелка влево
    If (LeftPressed) Then
        // Перемещение пушки влево
        RocketImage.Left := RocketImage.Left - ROCKET_SPEED;
    // Нажата ли стрелка вправо
    If (RightPressed) Then
        // Перемещение пушки вправо
        RocketImage.Left := RocketImage.Left + ROCKET_SPEED;
End;

End.
