Unit ImageUnit;

Interface

Uses
    VCL.Graphics, VCL.ExtCtrls, System.SysUtils, Vcl.Forms, GameFormUnit;

Const
    ROCKET_BULLET = 0;
    ALIEN_BULLET = 1;

Procedure LoadImage(Var Image: TImage; NameOfImage: String);
Procedure InitializeBullets(Var Bullets: TBulletArr);
Procedure LoadBitMap(Var BitMap: TBitMap; NameOfImage: String);
Procedure SetBackGround(Var BitMap: TBitMap);

Implementation

Procedure SetBackGround(Var BitMap: TBitMap);
Begin
    BitMap := TBitmap.Create;
    LoadBitMap(BitMap, 'BackGrounDImage');
End;

Procedure LoadImage(Var Image: TImage; NameOfImage: String);
Var
    ImagePath: String;
Begin
    ImagePath := ExtractFilePath(Application.ExeName);
    ImagePath := ImagePath + '\Images\' + NameOfImage + '.png';
    Image.Picture.LoadFromFile(ImagePath);
End;

Procedure LoadBitMap(Var BitMap: TBitMap; NameOfImage: String);
Var
    ImagePath: String;
Begin
    ImagePath := ExtractFilePath(Application.ExeName);
    ImagePath := ImagePath + '\Images\' + NameOfImage + '.bmp';
    BitMap.LoadFromFile(ImagePath);
End;

Procedure InitializeBullets(Var Bullets: TBulletArr);
Begin

    LoadImage(Bullets[ROCKET_BULLET], 'BulletRocket');
    LoadImage(Bullets[ALIEN_BULLET], 'BulletAlien');

End;

End.
