-- Заявки студента на вступление в курс (PENDING / APPROVED / REJECTED)

CREATE TYPE "JoinRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

CREATE TABLE "course_join_requests" (
    "id" TEXT NOT NULL,
    "course_id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "status" "JoinRequestStatus" NOT NULL DEFAULT 'PENDING',
    "message" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "reviewed_at" TIMESTAMP(3),

    CONSTRAINT "course_join_requests_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "course_join_requests_course_id_student_id_key"
    ON "course_join_requests"("course_id", "student_id");

ALTER TABLE "course_join_requests"
    ADD CONSTRAINT "course_join_requests_course_id_fkey"
    FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "course_join_requests"
    ADD CONSTRAINT "course_join_requests_student_id_fkey"
    FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
