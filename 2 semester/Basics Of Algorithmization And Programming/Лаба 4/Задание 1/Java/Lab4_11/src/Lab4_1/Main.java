package Lab4_1;

import java.io.*;
import java.util.Objects;
import java.util.Scanner;

public class Main {
    public record MySchedule (String elemSubject, String elemTeacher, String elemDayOfWeek, byte elemNumOfLesson) {
    }
    final static String RECFROMFILE = "1";
    final static String RECFROMCONSOLE = "2";
    final static String SAVE = "3";
    final static String SHOW = "4";
    final static String DELETE = "5";
    final static String ENDWORK = "6";
    final static String HELP = "7";
    final static String SHOWSCHEDULE = "8";
    final static String MONDAY = "Понедельник";
    final static String TUESDAY = "Вторник";
    final static String WEDNESDAY = "Среда";
    final static String THURSDAY = "Четверг";
    final static String FRIDAY = "Пятница";
    final static String SATURDAY = "Суббота";
    static void callHelp() {
        System.out.println("Для дополнения записей из файла необходимо в файле в первой строке ввести количество вводимых записей,\nзатем в каждой новой строке нужно вводить новый элемент добавляемой записи'+'(День недели(c большой буквы) -> Номер ' + 'пары(1..6) -> \nНазвание предмета(< 15 символов) -> ' + 'Имя преподавателя(< 15 символов).\n");
    }
    static void showMenu(){
        System.out.println("Введите " + RECFROMFILE + " для добавления записи из файла, " + RECFROMCONSOLE
                + " для добавления записи из консоли" + '\n'
                + "Введите " + SAVE + " для сохранения текущих записей в файл" + '\n'
                + "Введите " + SHOW + ", чтобы увидеть текущие записи" + '\n'
                + "Введите " + DELETE + ", чтобы удалить запись" + '\n'
                + "Введите " + ENDWORK + ", чтобы остановить программу" + '\n'
                + "Введите " + SHOWSCHEDULE + ", чтобы открыть расписание преподавателя" + '\n'
                + "Введите " + HELP + ", чтобы получить помощь");

    }
    static MySchedule[] addRecordsFromFile(String path, MySchedule[] myRecords){
        Scanner fin;
        MySchedule[] myRecordsFromFile;
        MySchedule myRecordFromFile;
        String dayOfWeek;
        String teacher;
        String subject;
        byte numOfLesson;
        subject = "";
        teacher = "";
        dayOfWeek = "";
        myRecordsFromFile = null;
        boolean canReadFile;
        int arraySize;
        canReadFile = true;
        arraySize = 0;
        numOfLesson = 0;
        fin = createFileStream(path);
        try {
            arraySize = Integer.parseInt(fin.nextLine());
        }
        catch (NumberFormatException formatException){
            System.err.print("Не корректная информация в файле\n");
            canReadFile = false;
        }
        if (canReadFile && (arraySize < 1  || arraySize > 100)) {
            System.err.print("Заданное число записей вне диапазона\n");
            canReadFile = false;
        }
        if (canReadFile) {
            myRecordsFromFile = new MySchedule[arraySize];
            for (int i = 0; i < arraySize; i++){
                for (int j = 1; j <= 4; j++){
                    if (!fin.hasNext() && canReadFile){
                        System.err.print("Не все элементы введены\n");
                        canReadFile = false;
                    }
                    else if (canReadFile){
                        if (j == 1){
                            dayOfWeek = fin.nextLine();
                            if (!(Objects.equals(dayOfWeek, MONDAY)) && !(Objects.equals(dayOfWeek, TUESDAY)) && !(Objects.equals(dayOfWeek, WEDNESDAY)) &&
                                    !(Objects.equals(dayOfWeek, THURSDAY)) && !(Objects.equals(dayOfWeek, FRIDAY)) && !(Objects.equals(dayOfWeek, SATURDAY))){
                                System.err.print("Не корректное заполнение файла\n");
                                canReadFile = false;
                            }
                        }
                        else if (j == 2){
                            try{
                                numOfLesson = Byte.parseByte(fin.nextLine());
                            }
                            catch(NumberFormatException formatException){
                                System.err.print("Не корректное заполнение файла\n");
                                canReadFile = false;
                            }
                            if (canReadFile && ((numOfLesson > 7) || (numOfLesson < 1))){
                                System.err.print("Не корректное заполнение файла\n");
                                canReadFile = false;
                            }
                        }
                        else if (j == 3){
                            subject = fin.nextLine();
                            if (subject.length() > 14){
                                System.err.print("Не корректное заполнение файла\n");
                                canReadFile = false;
                            }
                        }
                        else if (j == 4){
                            teacher = fin.nextLine();
                            if (teacher.length() > 14){
                                System.err.print("Не корректное заполнение файла\n");
                                canReadFile = false;
                            }
                        }
                    }
                }
                myRecordFromFile = new MySchedule(subject, teacher, dayOfWeek, numOfLesson);
                if (canReadFile){
                    for (int k = 0; k < myRecords.length; k++) {
                        if ((Objects.equals(myRecordFromFile.elemDayOfWeek, myRecords[k].elemDayOfWeek))
                                && (Objects.equals(myRecordFromFile.elemTeacher, myRecords[k].elemTeacher))
                                && (myRecordFromFile.elemNumOfLesson == myRecords[k].elemNumOfLesson)){
                            System.err.print("Один из элементов уже присутствует в записях\n");
                            canReadFile = false;
                        }
                    }
                    for (int k = 0; k < i; k++) {
                        if ((Objects.equals(myRecordFromFile.elemDayOfWeek, myRecordsFromFile[k].elemDayOfWeek))
                                && (Objects.equals(myRecordFromFile.elemTeacher, myRecordsFromFile[k].elemTeacher))
                                && (myRecordFromFile.elemNumOfLesson == myRecordsFromFile[k].elemNumOfLesson)){
                            System.err.print("Один из элементов уже присутствует в записях\n");
                            canReadFile = false;
                        }
                    }
                }
                if (canReadFile)
                    myRecordsFromFile[i] = myRecordFromFile;
            }
        }
        if (!canReadFile)
            myRecordsFromFile = new MySchedule[0];
        fin.close();
        return myRecordsFromFile;
    }
    static MySchedule[] addRecords(MySchedule[] backUpForMyRecords, MySchedule[] newRecords){
        MySchedule[] myRecords;
        myRecords = new MySchedule[newRecords.length + backUpForMyRecords.length];
        for (int i = 0; i < myRecords.length; i++){
            if (i < backUpForMyRecords.length)
                myRecords[i] = backUpForMyRecords[i];
            else
                myRecords[i] = newRecords[i - backUpForMyRecords.length];
        }
        return myRecords;
    }
    static MySchedule addRecordFromConsole(Scanner in){
        MySchedule newSchedule;
        boolean isIncorrect;
        String dayOfWeek;
        String teacher;
        String subject;
        byte numOfLesson;
        numOfLesson = -1;
        do {
            isIncorrect = false;
            System.out.println("Введите день недели (c большой буквы)");
            dayOfWeek = in.nextLine();
            if (!(Objects.equals(dayOfWeek, MONDAY)) && !(Objects.equals(dayOfWeek, TUESDAY)) && !(Objects.equals(dayOfWeek, WEDNESDAY)) &&
                    !(Objects.equals(dayOfWeek, THURSDAY)) && !(Objects.equals(dayOfWeek, FRIDAY)) && !(Objects.equals(dayOfWeek, SATURDAY))){
                System.err.print("Не корректная запись\n");
                isIncorrect = true;
            }
        } while(isIncorrect);
        do {
            isIncorrect = false;
            System.out.println("Введите номер пары (1..6)");
            try {
                numOfLesson = Byte.parseByte(in.nextLine());
            }
            catch(NumberFormatException formatException){
                System.err.print("Не корректная запись\n");
                isIncorrect = true;
            }
            if (!isIncorrect && (numOfLesson < 1 || numOfLesson > 6)){
                System.err.print("Значение не входит в диапазон\n");
                isIncorrect = true;
            }
        } while(isIncorrect);
        do {
            isIncorrect = false;
            System.out.println("Введите название предмета (< 15 символов)");
            subject = in.nextLine();
            if (subject.length() > 14){
                System.err.print("Слишком длинная запись\n");
                isIncorrect = true;
            }
        } while(isIncorrect);
        do {
            isIncorrect = false;
            System.out.println("Введите имя преподователя (< 15 символов)");
            teacher = in.nextLine();
            if (teacher.length() > 14){
                System.err.print("Слишком длинная запись\n");
                isIncorrect = true;
            }
        } while(isIncorrect);
        newSchedule = new MySchedule(subject, teacher, dayOfWeek, numOfLesson);
        return  newSchedule;
    }
    static void saveRecordsToFile(MySchedule[] myRecords, String path) {
        Writer writer;
        File file;
        file = new File(path);
        try {
            writer = new FileWriter(file);
            writer.append(String.valueOf(myRecords.length)).append("\n");
            for (int k = 0; k < myRecords.length; k++) {
                writer.append(myRecords[k].elemDayOfWeek).append("\n");
                writer.append(String.valueOf(myRecords[k].elemNumOfLesson)).append("\n");
                writer.append(myRecords[k].elemSubject).append("\n");
                writer.append(myRecords[k].elemTeacher).append("\n");
            }
            writer.append('\n');
            writer.close();
            System.out.println("Запись в файл прошла успешно");
        }
        catch (IOException ioException){
            System.out.println("Не удалось записать в файл");
        }
    }
    static byte enterDeletedRecord(Scanner in, int restriction){
        byte numOfRecord;
        boolean isInCorrect;
        numOfRecord = -1;
        System.out.println("Введите номер удаляемой записи (1.." + (restriction) + ")");
        do {
            isInCorrect = false;
            try{
                numOfRecord = Byte.parseByte(in.nextLine());
            }
            catch(NumberFormatException formatException){
                isInCorrect = true;
                System.err.print("Введите число\n");
            }
            if (!isInCorrect && ((numOfRecord) > (restriction)  || (numOfRecord) < 1)){
                isInCorrect = true;
                System.err.print("Введите число в допустимом диапазоне\n");
            }
        } while(isInCorrect);
        numOfRecord--;
        return numOfRecord;
    }
    static MySchedule[] deleteRecord(MySchedule[] myRecords,Scanner in){
        byte numOfRecord;
        MySchedule[] myNewRecords;
        myNewRecords = new MySchedule[myRecords.length - 1];
        numOfRecord = enterDeletedRecord(in, myRecords.length );
        for (int i = 0; i < myRecords.length - 1; i++) {
            if (i < numOfRecord) {
                myNewRecords[i] = myRecords[i];
            }
            else {
                myNewRecords[i] = myRecords[i + 1];
            }
        }
        return myNewRecords;
    }
    static void showRecords(MySchedule[] myRecords){
        System.out.println("Записи вида (День недели, номер пары, предмет, учитель");
        for (int i = 0; i < myRecords.length; i++)
            System.out.println("Запись " + i + ": " + myRecords[i].elemDayOfWeek + " " + myRecords[i].elemNumOfLesson + " " + myRecords[i].elemSubject + " " + myRecords[i].elemTeacher);
        System.out.println();
    }
    static String[] createSchedule(MySchedule[] myRecords, String teacher){
        String[] schedule;
        schedule = new String[36];
        for (int j = 0; j < 35; j++)
            schedule[j] = "";
        for (int i = 0; i < myRecords.length; i++) {
            if (Objects.equals(myRecords[i].elemTeacher, teacher)) {
                if (Objects.equals(myRecords[i].elemDayOfWeek, MONDAY)) {
                    schedule[myRecords[i].elemNumOfLesson - 1] = myRecords[i].elemSubject;
                } else if (Objects.equals(myRecords[i].elemDayOfWeek, TUESDAY)) {
                    schedule[5 + myRecords[i].elemNumOfLesson] = myRecords[i].elemSubject;
                } else if (Objects.equals(myRecords[i].elemDayOfWeek, WEDNESDAY)) {
                    schedule[11 + myRecords[i].elemNumOfLesson] = myRecords[i].elemSubject;
                } else if (Objects.equals(myRecords[i].elemDayOfWeek, THURSDAY)) {
                    schedule[17 + myRecords[i].elemNumOfLesson] = myRecords[i].elemSubject;
                } else if (Objects.equals(myRecords[i].elemDayOfWeek, FRIDAY)) {
                    schedule[23 + myRecords[i].elemNumOfLesson] = myRecords[i].elemSubject;
                } else if (Objects.equals(myRecords[i].elemDayOfWeek, SATURDAY)) {
                    schedule[29 + myRecords[i].elemNumOfLesson] = myRecords[i].elemSubject;
                }
            }
        }
        return schedule;
    }
    static void showSchedule(MySchedule[] myRecords, String teacher){
        String[] schedule;
        schedule = new String[36];
        schedule = createSchedule(myRecords, teacher);
        System.out.println(MONDAY + ": ");
        for (int i = 1; i < 6; i++){
            if (!Objects.equals(schedule[i - 1], ""))
                System.out.print(i + " пара: " + schedule[i - 1]);
        }
        System.out.println("\n" + TUESDAY + ": ");
        for (int i = 1; i < 6; i++){
            if (!Objects.equals(schedule[i + 5], ""))
                System.out.print(i + " пара: " + schedule[i + 5]);
        }
        System.out.println("\n" + WEDNESDAY + ": ");
        for (int i = 1; i < 6; i++){
            if (!Objects.equals(schedule[i + 11], ""))
                System.out.print(i + " пара: " + schedule[i + 11]);
        }
        System.out.println("\n" + THURSDAY + ": ");
        for (int i = 1; i < 6; i++){
            if (!Objects.equals(schedule[i + 17], ""))
                System.out.print(i + " пара: " + schedule[i + 17]);
        }
        System.out.println("\n" + FRIDAY + ": ");
        for (int i = 1; i < 6; i++){
            if (!Objects.equals(schedule[i + 23], ""))
                System.out.print(i + " пара: " + schedule[i + 23]);
        }
        System.out.println("\n" + SATURDAY + ": ");
        for (int i = 1; i < 6; i++){
            if (!Objects.equals(schedule[i + 29], ""))
                System.out.print(i + " пара: " + schedule[i + 29]);
        }
        System.out.println();
    }
    static String enterTeacherName(Scanner in){
        String teacher;
        boolean isInCorrect;
        do {
            isInCorrect = false;
            System.out.println("Введите имя преподователя (< 15 символов)");
            teacher = in.nextLine();
            if (teacher.length() > 14){
                System.err.print("Слишком длинная запись\n");
                isInCorrect = true;
            }
        } while(isInCorrect);
        return teacher;
    }
    static void callMenu(Scanner in){
        String path;
        String instructions;
        String teacher;
        MySchedule[] myRecords;
        MySchedule[] backUpForMyRecords;
        MySchedule[] newRecords;
        myRecords = new MySchedule[0];
        instructions = "";
        while (!Objects.equals(instructions, ENDWORK)){
            showMenu();
            instructions = in.nextLine();
            if (Objects.equals(instructions, RECFROMFILE)) {
                backUpForMyRecords = myRecords;
                path = inputPathToFile(in);
                newRecords = addRecordsFromFile(path, myRecords);
                myRecords = addRecords(backUpForMyRecords, newRecords);
            }
            else if (Objects.equals(instructions, RECFROMCONSOLE)) {
                backUpForMyRecords = myRecords;
                newRecords = new MySchedule[1];
                newRecords[0] = addRecordFromConsole(in);
                myRecords = addRecords(backUpForMyRecords, newRecords);
            }
            else if (Objects.equals(instructions, SAVE)) {
                if (myRecords.length > 0) {
                    path = inputPathToFile(in);
                    saveRecordsToFile(myRecords, path);
                }
                else
                    System.err.println("Нет записей");
            }
            else if (Objects.equals(instructions, SHOW)) {
                if (myRecords.length > 0)
                    showRecords(myRecords);
                else
                    System.err.println("Нет записей");
            }
            else if (Objects.equals(instructions, DELETE)){
                if (myRecords.length > 0)
                    myRecords = deleteRecord(myRecords, in);
                else
                    System.err.println("Нет записей");
            }
            else if (Objects.equals(instructions, HELP))
                callHelp();
            else if (Objects.equals(instructions, SHOWSCHEDULE)) {
                if (myRecords.length > 0) {
                    teacher = enterTeacherName(in);
                    showSchedule(myRecords, teacher);
                }
                else
                    System.err.println("Нет записей");
            }
            else if (!Objects.equals(instructions, ENDWORK))
                System.err.println("Неверная комманда");
        }

    }
    static boolean isFileExists(String path){
        boolean isNotCorrect;
        isNotCorrect = false;
        File inputFile;
        inputFile = new File(path);
        if (!inputFile.exists()) {
            System.err.println("Файл не существует. Повторите ввод:");
            isNotCorrect = true;
        }
        return (isNotCorrect);
    }
    static boolean isTypeCorrect(String path){
        boolean isNotCorrect;
        isNotCorrect = false;
        if (!path.endsWith(".txt")) {
                System.err.println("Файл должен быть формата .txt. Повторите ввод:");
            isNotCorrect = true;
        }
        return (isNotCorrect);
    }
    static String inputPathToFile(Scanner in){
        String path;
        boolean isNotCorrect;
        System.out.println("Укажите путь к файлу");
        do{
            isNotCorrect = false;
            path = in.nextLine();
            isNotCorrect = isFileExists(path);
            if (!isNotCorrect)
                isNotCorrect = isTypeCorrect(path);
        } while(isNotCorrect);
        return(path);
    }
    static Scanner createFileStream(String path){
        Scanner fin;
        File file;
        fin = null;
        file = new File(path);
        try {
            fin = new Scanner(file);
        }
        catch (FileNotFoundException e) {
            System.out.println("Нельзя прочесть файл");
        }
        return fin;
    }
    public static void main(String[] args){
        Scanner in;
        in = new Scanner(System.in);
        callMenu(in);
        in.close();
    }
}


