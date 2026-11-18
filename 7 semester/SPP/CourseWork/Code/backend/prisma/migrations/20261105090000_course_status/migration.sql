-- Публикация курсов: статус DRAFT/PUBLISHED + дата публикации
CREATE TYPE "CourseStatus" AS ENUM ('DRAFT', 'PUBLISHED');

ALTER TABLE "courses" ADD COLUMN "status" "CourseStatus" NOT NULL DEFAULT 'DRAFT';
ALTER TABLE "courses" ADD COLUMN "published_at" TIMESTAMP(3);

-- Сохраняем ранее опубликованные курсы
UPDATE "courses"
SET "status" = 'PUBLISHED', "published_at" = NOW()
WHERE "is_published" = true;

ALTER TABLE "courses" DROP COLUMN "is_published";
