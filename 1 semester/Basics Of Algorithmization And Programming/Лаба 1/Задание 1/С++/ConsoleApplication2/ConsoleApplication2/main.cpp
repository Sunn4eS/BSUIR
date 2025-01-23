#include <iostream>

using namespace std;
int main()
{
	setlocale(LC_ALL, "Russian");

	const int MIN_MONTH = 1, MAX_MONTH = 12;
	int numOfMonth;
	bool isIncorrect;

	cout << "������ ��������� �������� ���� ���� �� ������ ������.\n\n";

	do 
	{
		isIncorrect = false;
		cout << "������� ����� ������:\n";
		cin >> numOfMonth;
		if (cin.fail())
		{
			isIncorrect = true;
			cout << "����� ������������ ������ ������!\n";
			cin.clear();
			while (cin.get() != '\n');
		}
		if (cin.get() != '\n')
		{
			isIncorrect = true;
			cout << "������ �����\n";
			cin.clear();
			while (cin.get() != '\n');
			cout << endl;
		}
		if (!isIncorrect && (numOfMonth < MIN_MONTH || numOfMonth > MAX_MONTH))
		{
			isIncorrect = true;
			cout << "��� ���������!\n";
		}
	} while (isIncorrect);
	
	if (numOfMonth < 6 && numOfMonth > 2)
	{
	    cout << "�����";
	}
	if (numOfMonth > 8 && numOfMonth < 12)
	{
		cout << "�����";
	}
    if (numOfMonth > 5 && numOfMonth < 9) 
	{
		cout << "����";
	}
	if ((numOfMonth == 12) || (numOfMonth == 1) || (numOfMonth == 2))
	{
		cout << "����";
	}
	return 0;
}