CREATE TYPE "Role" AS ENUM ('TEACHER', 'STUDENT');

CREATE TYPE "TaskType" AS ENUM ('EAR_TRAINING', 'PLAY_PRACTICE');

CREATE TYPE "TaskResultStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'CORRECT', 'INCORRECT', 'SKIPPED');

CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "role" "Role" NOT NULL,
    "avatar_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "teacher_students" (
    "id" TEXT NOT NULL,
    "teacher_id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "teacher_students_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "courses" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "is_published" BOOLEAN NOT NULL DEFAULT false,
    "teacher_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "courses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "tasks" (
    "id" TEXT NOT NULL,
    "course_id" TEXT NOT NULL,
    "type" "TaskType" NOT NULL,
    "title" TEXT NOT NULL,
    "instruction" TEXT,
    "audio_content" TEXT,
    "answer_options" JSONB,
    "expected_note" TEXT,
    "tolerance_cents" INTEGER NOT NULL DEFAULT 20,
    "correct_answer" TEXT,
    "order_index" INTEGER NOT NULL DEFAULT 0,
    "is_template" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tasks_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "student_courses" (
    "id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "course_id" TEXT NOT NULL,
    "progress" INTEGER NOT NULL DEFAULT 0,
    "enrolled_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),

    CONSTRAINT "student_courses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "task_results" (
    "id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "task_id" TEXT NOT NULL,
    "status" "TaskResultStatus" NOT NULL DEFAULT 'PENDING',
    "answer" TEXT,
    "reaction_ms" INTEGER,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "live_session_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "task_results_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "live_sessions" (
    "id" TEXT NOT NULL,
    "teacher_id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "room_code" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ended_at" TIMESTAMP(3),

    CONSTRAINT "live_sessions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "live_task_cards" (
    "id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "task_id" TEXT,
    "status" "TaskResultStatus" NOT NULL DEFAULT 'PENDING',
    "card_data" JSONB,
    "sent_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),

    CONSTRAINT "live_task_cards_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE UNIQUE INDEX "teacher_students_teacher_id_student_id_key" ON "teacher_students"("teacher_id", "student_id");

CREATE UNIQUE INDEX "student_courses_student_id_course_id_key" ON "student_courses"("student_id", "course_id");

CREATE UNIQUE INDEX "live_sessions_room_code_key" ON "live_sessions"("room_code");

ALTER TABLE "teacher_students" ADD CONSTRAINT "teacher_students_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "teacher_students" ADD CONSTRAINT "teacher_students_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "courses" ADD CONSTRAINT "courses_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "tasks" ADD CONSTRAINT "tasks_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "student_courses" ADD CONSTRAINT "student_courses_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "student_courses" ADD CONSTRAINT "student_courses_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "task_results" ADD CONSTRAINT "task_results_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "task_results" ADD CONSTRAINT "task_results_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "live_sessions" ADD CONSTRAINT "live_sessions_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "live_sessions" ADD CONSTRAINT "live_sessions_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "live_task_cards" ADD CONSTRAINT "live_task_cards_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "live_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "live_task_cards" ADD CONSTRAINT "live_task_cards_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE SET NULL ON UPDATE CASCADE;
