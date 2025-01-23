Unit AlienUnit;

Interface

Uses
    Vcl.ExtCtrls, Vcl.Graphics, System.Types, Math, DateUtils;

Const
    DOWN_SH = 110;
    SIDE_SH = 120;
    START_X_POS = 50;
    START_Y_POS = 100;

    ALIEN_SPEED = 30;
    ALIEN_DOWN_SPEED = 30;

    ALIEN_BULLET_SPEED = 50;

    SPEED_COEFF = 1;
    ALIENS_ROW = 4;
    ALIENS_COL = 9;
    ALIENS_COUNT_IN_COL = 10;

    ALIENS_RED_SCORE = 40;
    ALIENS_GREEN_SCORE = 30;
    ALIENS_PURPLE_SCORE = 30;
    ALIENS_BLUE_SCORE = 20;
    ALIENS_YELLOW_SCORE = 10;

Type
    TAlienRec = Record
        Image: TBitMap;
        Killed: Boolean;
        CanShoot: Boolean;
        PosX: Integer;
        PosY: Integer;
        Score: Integer;
    End;

    TAlienBulletRec = Record
        Image: TBitMap;
        PosX: Integer;
        PosY: Integer;
        Visible: Boolean;
    End;

    TAlien = Array [0 .. 4] Of Array [0 .. 9] Of TAlienRec;
    TAlienBullet = Array [0 .. 9] Of TAlienBulletRec;

Procedure InitializeAlienBullets(Var AliensBullets: TAlienBullet);
Procedure InitializeAliens(Var Aliens: TAlien);
Procedure SetAliensStartPos(Var Aliens: TAlien);
Function CalculateAlienHitBox(Alien: TAlienRec): TRect;
Procedure MoveAliens(Var Aliens: TAlien; LeftSide, RightSide, DownSide: Integer;
  Var Direction: Boolean);
Function FindBorderColumn(Aliens: TAlien; IsFirstCol: Boolean): Integer;
Procedure ShootAlienBullet(Var Aliens: TAlien; Var Bullets: TAlienBullet);
Function CalculateAlienBulletHitBox(AlienBullet: TAlienBulletRec): TRect;
Function CheckAlienBulletCollision(Const AlienBullet: TAlienBulletRec;
  Const Rocket: TImage): Boolean;
Procedure MoveAlienBullet(Var RocketImage: TImage;
  Var AlienBullet: TAlienBullet; Const DownSide: Integer; Var Lives: Integer);
Procedure KillAlien(Var Alien: TAlienRec; Var BulletImage: TImage;
  Var IsShoot: Boolean; Var Score: Integer);
Function CheckBorderOfRocket(Aliens: TAlien; Rocket: TImage): Boolean;

Implementation

Uses
    ImageUnit;

Function CheckBorderOfRocket(Aliens: TAlien; Rocket: TImage): Boolean;
Var
    RocketHitBox: TRect;
    InterS: Boolean;
    I, J: Integer;
Begin
    InterS := False;
    RocketHitBox := Rect(Rocket.Left, Rocket.Top, Rocket.Left + Rocket.Width,
      Rocket.Top + Rocket.Height);

    For I := 0 To ALIENS_ROW Do
        For J := 0 To ALIENS_COL Do
            If Not Aliens[I, J].Killed Then
                InterS := IntersectRect(CalculateAlienHitBox(Aliens[I, J]),RocketHitBox) Or (Aliens[I, J].PosY + Aliens[I, J].Image.Width > Rocket.Top);

    CheckBorderOfRocket := InterS;
End;

Procedure MoveAlienBullet(Var RocketImage: TImage; Var AlienBullet: TAlienBullet; Const DownSide: Integer; Var Lives: Integer);
Var
    I: Integer;
Begin
    // Проходимся по всем снарядам врагов
    For I := 0 To High(AlienBullet) Do
    Begin
        // Проверяем наличие снаряда на экране 
        If AlienBullet[I].Visible Then
        Begin
            // Смещаем снаряд вниз
            AlienBullet[I].PosY := AlienBullet[I].PosY + ALIEN_BULLET_SPEED;
            // Проверяем пересек ли снаряд пушку
            If CheckAlienBulletCollision(AlienBullet[I], RocketImage) Then
            Begin
                // Убираем снаряд с игрового поля
                AlienBullet[I].Visible := False;
                // Отнимаем одну жизнь пушке
                Dec(Lives);
            End;
            // Проверяем пересек ли снаряд нижнюю границу поля
            If (AlienBullet[I].PosY > DownSide) Then
            Begin
                // Убираем снаряд с игрового поля
                AlienBullet[I].Visible := False;
            End;
        End;
    End;
End;

Function CheckAlienBulletCollision(Const AlienBullet: TAlienBulletRec;
  Const Rocket: TImage): Boolean;
Var
    AlienBulletHitBox: TRect;
    RocketHitBox: TRect;
Begin
    RocketHitBox := Rect(Rocket.Left, Rocket.Top, Rocket.Left + Rocket.Width,
      Rocket.Top + Rocket.Height);
    AlienBulletHitBox := CalculateAlienBulletHitBox(AlienBullet);

    CheckAlienBulletCollision := IntersectRect(AlienBulletHitBox, RocketHitBox);
End;

Function CalculateAlienBulletHitBox(AlienBullet: TAlienBulletRec): TRect;
Var
    ImageWidth, ImageHeight: Integer;
    HitBoxLeft, HitBoxRight, HitBoxTop, HitBoxBottom: Integer;
    HitBox: TRect;
Begin
    // Сохранение ширины врага 
    ImageWidth := AlienBullet.Image.Width;
    // Сохранение высоты врага
    ImageHeight := AlienBullet.Image.Height;
    // Сохранение левой границы врага
    HitBoxLeft := AlienBullet.PosX;
    // Сохранение правой границы врага
    HitBoxRight := HitBoxLeft + ImageWidth;
    // Сохранение верхней границы врага
    HitBoxTop := AlienBullet.PosY;
    // Сохранение нижней границы врага
    HitBoxBottom := HitBoxTop + ImageHeight;
    // Рассчёт границ врага
    HitBox := Rect(HitBoxLeft, HitBoxTop, HitBoxRight, HitBoxBottom);
    CalculateAlienBulletHitBox := HitBox;
End;

Procedure InitializeAlienBullets(Var AliensBullets: TAlienBullet);
Var
    I: Integer;
Begin
    For I := 0 To High(AliensBullets) Do
    Begin
        AliensBullets[I].Image := TBitMap.Create;;
        AliensBullets[I].PosX := 0;
        AliensBullets[I].PosY := 0;
        AliensBullets[I].Visible := False;
        LoadBitMap(AliensBullets[I].Image, 'AlienBullet');
    End;

End;

Function FindShootingAliens(Aliens: TAlien): Integer;
Var
    I: Integer;
    Count: Integer;
Begin
    Count := 0;
    For I := 0 To ALIENS_COL Do
    Begin
        If Not Aliens[0, I].Killed Then
        Begin
            Inc(Count);
        End;
    End;

    FindShootingAliens := Count;
End;

Procedure ShootAlienBullet(Var Aliens: TAlien; Var Bullets: TAlienBullet);
Var
    CurrAlien: Integer;
Begin
    // Изменение семени случайности
    Randomize;
    // Возвращение случайнго числа в диапазоне 10
    CurrAlien := RandomRange(1, 11) - 1;
    // Уничтожен ли враг в верхнем ряду
    If Not Aliens[0, CurrAlien].Killed Then
    Begin
        // Рассчет координаты Х для снаряда врага
        Bullets[CurrAlien].PosX := (Aliens[0, CurrAlien].PosX + Aliens[0, CurrAlien].Image.Width);
        // Рассчет координаты Y для снаряда врага
        Bullets[CurrAlien].PosY := (Aliens[0, CurrAlien].PosY + Aliens[0, CurrAlien].Image.Width);
        // Создание снарда на экране
        Bullets[CurrAlien].Visible := True;
    End;
End;

Procedure KillAlien(Var Alien: TAlienRec; Var BulletImage: TImage; Var IsShoot: Boolean; Var Score: Integer);
Begin
    // Удаление снаряда пушки с игрового поля 
    BulletImage.Visible := False;
    // Возобновление возможности выстрела пушки
    IsShoot := False;
    // Перевод состояния врага в уничтоженное 
    Alien.Killed := True;
    BulletImage.Top := 0;
    // Очищение изображения врага 
    Alien.Image.Destroy;
    // Обновление счёта игрока
    Score := Score + Alien.Score;
End;

Procedure MoveAliensDirection(Var Aliens: TAlien;
  Var Right, Left, Down: Boolean);
Var
    I, J: Integer;
Begin
    If Left Then
    Begin
        For I := 0 To ALIENS_ROW Do
        Begin
            For J := 0 To ALIENS_COL Do
            Begin
                Aliens[I, J].PosX := Aliens[I, J].PosX - ALIEN_SPEED;
            End;
        End;
    End;

    If Right Then
    Begin
        For I := 0 To ALIENS_ROW Do
        Begin
            For J := 0 To ALIENS_COL Do
            Begin
                Aliens[I, J].PosX := Aliens[I, J].PosX + ALIEN_SPEED;
            End;
        End;
    End;

    If Down Then
    Begin
        For I := 0 To ALIENS_ROW Do
        Begin
            For J := 0 To ALIENS_COL Do
            Begin
                Aliens[I, J].PosY := Aliens[I, J].PosY + ALIEN_DOWN_SPEED;
            End;
        End;
    End;

End;

Function FindBorderColumn(Aliens: TAlien; IsFirstCol: Boolean): Integer;
Var
    I, J, LastCol, FirstCol, CountInCol: Integer;
Begin
    // Установка левой границы
    LastCol := ALIENS_COL;
    // Устаноква правой границы
    FirstCol := 0;
    // Количество в столбце
    CountInCol := 0;

    // Первый ли столбец врагов
    If IsFirstCol Then
    Begin
        // Проход по всем врагам
        For J := ALIENS_COL DownTo 0 Do
        Begin
            For I := 0 To ALIENS_ROW Do
            Begin
                // Уничтожен ли враг в столбце
                If Not Aliens[I, J].Killed Then
                Begin
                    // Увеличиваем счётчик уничтоженых врагов
                    Inc(CountInCol);
                End;

            End;
            // Проверка количества врагов в столбце
            If CountInCol > 0 Then
                // Смещение первого столбца врагов
                FirstCol := J;
            // Обнуление счетчика врагов в столбце
            CountInCol := 0;
        End;
        
        FindBorderColumn := FirstCol;
    End
    Else
    Begin
        // Проход по всем врагам
        For J := 0 To ALIENS_COL Do
        Begin
            For I := 0 To ALIENS_ROW Do
            Begin
                // Уничтожен ли враг в столбце
                If Not Aliens[I, J].Killed Then
                Begin
                    Inc(CountInCol);
                End;

            End;
            If CountInCol > 0 Then
                LastCol := J;
            CountInCol := 0;
        End;
        FindBorderColumn := LastCol;
    End;

End;

Procedure MoveAliens(Var Aliens: TAlien; LeftSide, RightSide, DownSide: Integer;
  Var Direction: Boolean);
Var

    Down, Left, Right: Boolean;
    CrossRight, CrossLeft: Boolean;

Begin
    CrossRight := Aliens[0, FindBorderColumn(Aliens, False)].PosX + Aliens[0, 9]
      .Image.Width + ALIEN_SPEED > RightSide;
    CrossLeft := Aliens[0, FindBorderColumn(Aliens, True)].PosX - 30 < 0;

    If CrossRight And Not CrossLeft Then
    Begin
        Left := False;
        Right := False;
        Down := True;
        MoveAliensDirection(Aliens, Right, Left, Down);
        Direction := False;
    End;

    If Not CrossRight And CrossLeft Then
    Begin
        Left := False;
        Right := False;
        Down := True;
        MoveAliensDirection(Aliens, Right, Left, Down);
        Direction := True;
    End;

    If Not CrossRight And Direction Then
    Begin
        Down := False;
        Right := True;
        Left := False;
        MoveAliensDirection(Aliens, Right, Left, Down);
    End;

    If Not CrossLeft And Not Direction Then
    Begin
        Down := False;
        Right := False;
        Left := True;
        MoveAliensDirection(Aliens, Right, Left, Down);
    End;

End;

Function CalculateAlienHitBox(Alien: TAlienRec): TRect;
Var
    ImageWidth, ImageHeight: Integer;
    HitBoxLeft, HitBoxRight, HitBoxTop, HitBoxBottom: Integer;
    HitBox: TRect;
Begin
    ImageWidth := Alien.Image.Width;
    ImageHeight := Alien.Image.Height;

    HitBoxLeft := Alien.PosX;
    HitBoxRight := HitBoxLeft + ImageWidth;

    HitBoxTop := Alien.PosY;
    HitBoxBottom := HitBoxTop + ImageHeight;

    HitBox := Rect(HitBoxLeft, HitBoxTop, HitBoxRight, HitBoxBottom);

    CalculateAlienHitBox := HitBox;
End;

Procedure InitializeAliens(Var Aliens: TAlien);
Var
    I, J: Integer;
Begin
    For I := 0 To 4 Do
    Begin
        For J := 0 To 9 Do
        Begin

            Aliens[I, J].Image := TBitMap.Create;
            Aliens[I, J].Killed := False;
            Aliens[I, J].CanShoot := False;
            Aliens[I, J].PosX := 0;
            Aliens[I, J].PosY := 0;

            If I = 0 Then
            Begin

                LoadBitMap(Aliens[I, J].Image, 'RedAlien');
                Aliens[I, J].CanShoot := True;
                Aliens[I, J].Score := ALIENS_RED_SCORE;
            End;
            If I = 1 Then
            Begin
                LoadBitMap(Aliens[I, J].Image, 'GreenAlien');
                Aliens[I, J].Score := ALIENS_GREEN_SCORE;
            End;
            If I = 2 Then
            Begin
                LoadBitMap(Aliens[I, J].Image, 'PurpleAlien');
                Aliens[I, J].Score := ALIENS_PURPLE_SCORE;
            End;
            If I = 3 Then
            Begin
                LoadBitMap(Aliens[I, J].Image, 'BlueAlien');
                Aliens[I, J].Score := ALIENS_BLUE_SCORE;
            End;
            If I = 4 Then
            Begin
                LoadBitMap(Aliens[I, J].Image, 'YellowAlien');
                Aliens[I, J].Score := ALIENS_YELLOW_SCORE;
            End;
        End;
    End;

End;

Procedure SetAliensStartPos(Var Aliens: TAlien);
Var
    I, J: Integer;
Begin
    For I := 0 To 4 Do
    Begin
        For J := 0 To 9 Do
        Begin

            If I = 0 Then
            Begin
                Aliens[I, J].PosX := J * SIDE_SH + START_X_POS;
                Aliens[I, J].PosY := START_Y_POS;
            End;

            If I = 1 Then
            Begin
                Aliens[I, J].PosX := J * SIDE_SH + START_X_POS;
                Aliens[I, J].PosY := START_Y_POS + DOWN_SH * I;
            End;

            If I = 2 Then
            Begin
                Aliens[I, J].PosX := J * SIDE_SH + START_X_POS;
                Aliens[I, J].PosY := START_Y_POS + DOWN_SH * I;
            End;

            If I = 3 Then
            Begin
                Aliens[I, J].PosX := J * SIDE_SH + START_X_POS;
                Aliens[I, J].PosY := START_Y_POS + DOWN_SH * I;
            End;

            If I = 4 Then
            Begin
                Aliens[I, J].PosX := J * SIDE_SH + START_X_POS;
                Aliens[I, J].PosY := START_Y_POS + DOWN_SH * I;
            End;

        End;
    End;

End;

End.
