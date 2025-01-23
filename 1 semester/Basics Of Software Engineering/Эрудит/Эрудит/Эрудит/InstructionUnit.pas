unit InstructionUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TInstructionForm = class(TForm)
    InstructionScrollBox: TScrollBox;
    InstructionLabel: TLabel;
    procedure InstructionFormOnCreate(Sender: TObject);
    procedure InstructionScrollBoxMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure InstructionScrollBoxMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InstructionForm: TInstructionForm;

implementation

{$R *.dfm}

procedure TInstructionForm.InstructionFormOnCreate(Sender: TObject);
begin
    InstructionLabel.Caption := 'Начало: Выберите один из двух языков, на котором будут составлены слова. Выберите количество игроков от 2 до 5. '#13#10#13#10 +
                                'Процесс игры: Все игроки по очереди составляют слова, каждый из своего НАБОРА БУКВ ИГРОКА. ' +
                                'Если слово составлено верно, то игроку присуждаются очки, по сумме равные количеству букв в слове. ' +
                                'Если слово игрока начинается с той же буквы, на которую заканчивалось слово предыдущего игрока, то количество очков, присужденных за текущий ход, удваивается. ' +
                                'Использованные буквы из НАБОРА БУКВ ИГРОКА удаляются и считаются отыгравшими. ' +
                                'Слово составлено неверно, если в него входят буквы, не входящие в НАБОР БУКВ ИГРОКА (одну и ту же букву из НАБОРА БУКВ ИГРОКА нельзя использовать несколько, раз). ' +
                                'Слово составлено неверно, если его нет в СЛОВАРЕ ВОЗМОЖНЫХ СЛОВ и игроки отказываются занести данное слово в СЛОВАРЬ ВОЗМОЖНЫХ СЛОВ. ' +
                                'Если слово составлено неверно, то из общей суммы очков игрока вычитается число очков, равное количеству букв в неверно составленном слове. Сами буквы из НАБОРА БУКВ не удаляются. ' +
                                'Если игрок не может составить слово, он пропускает ход. Введенная пустая строка равносильна пропуску хода. За пропуск хода очки не снимаются. ' +
                                'После того, как каждый игрок сделал свой ход, перед следующим ходом из БАНКА БУКВ ему добавляется недостающее до 10-ти количество букв в НАБОР БУКВ ИГРОКА. '#13#10#13#10 +
                                'Бонусы: За игру, каждый игрок может воспользоваться двумя бонусами: «50-на-50» и «помощь друга».' +
                                '«50-на-50» — игрок может перечислить 5 букв, которые он хотел бы заменить. Эти буквы ИЗ НАБОРА БУКВ ИГРОКА удаляются, а вместо них случайным образом выбираются очередные 5 букв, которые он хотел бы заменить. ' +
                                'Эти буквы из НАБОРА БАНКА БУКВ. При этом замененные буквы считаются, отыгравшими и обратно в БАНК не заносятся, а сумма очков игрока уменьшается на 2.' +
                                '«помощь друга» -- игрок может заменить «ненужную» ему букву из своего НАБОРА БУКВ ИГРОКА на «Понравившуюся» ему букву из НАБОРА БУКВ ИГРОКА соперника. ' +
                                ' При этом согласие второго не требуется и сумма очков не уменьшается. Игроку нужно указать свою букву, которую он хочет заменить, номер соперника и букву в НАБОРЕ БУКВ соперника для замены. '#13#10#13#10 +
                                'Окончание: Окончанием игры будет являться пропуск хода всеми игроками. Выигрывает тот игрок, который набрал большее число баллов.';
end;

procedure TInstructionForm.InstructionScrollBoxMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    InstructionScrollBox.VertScrollBar.Position:= InstructionScrollBox.VertScrollBar.Position + 12;
end;


procedure TInstructionForm.InstructionScrollBoxMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    InstructionScrollBox.VertScrollBar.Position:= InstructionScrollBox.VertScrollBar.Position - 12;
end;

end.
