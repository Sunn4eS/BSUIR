using System;
using System.IO;

namespace lab1_obj_parser
{
    public class TgaTexture : Texture
    {
        private TgaTexture(int width, int height, int[] pixels) : base(width, height, pixels) { }

        public static new Texture Load(string path)
        {
            using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read))
            using (BinaryReader reader = new BinaryReader(fs))
            {
                // Чтение заголовка
                byte idLength = reader.ReadByte();
                byte colorMapType = reader.ReadByte();
                byte imageType = reader.ReadByte();
                reader.ReadBytes(5); // цветовая карта (не используется)
                ushort xOrigin = reader.ReadUInt16();
                ushort yOrigin = reader.ReadUInt16();
                ushort width = reader.ReadUInt16();
                ushort height = reader.ReadUInt16();
                byte bitsPerPixel = reader.ReadByte();
                byte descriptor = reader.ReadByte();

                // Проверка типа
                if (imageType != 2 && imageType != 3 && imageType != 10 && imageType != 11)
                    throw new NotSupportedException($"Неподдерживаемый тип TGA: {imageType}. Ожидались 2,3,10,11");

                // bitsPerPixel может быть 8, 24 или 32
                if (bitsPerPixel != 8 && bitsPerPixel != 24 && bitsPerPixel != 32)
                    throw new NotSupportedException($"Неподдерживаемая глубина цвета: {bitsPerPixel} бит");

                if (idLength > 0)
                    reader.ReadBytes(idLength);

                int pixelCount = width * height;
                int srcBytesPerPixel = bitsPerPixel / 8; // 1, 3 или 4
                byte[] rawData;

                // Распаковка RLE для типов 10 и 11
                if (imageType == 10 || imageType == 11)
                {
                    rawData = DecompressRle(reader, pixelCount, srcBytesPerPixel);
                }
                else // типы 2 и 3
                {
                    rawData = reader.ReadBytes(pixelCount * srcBytesPerPixel);
                }

                // Преобразование в 32-битный ARGB (всегда RGBA)
                int[] pixels = new int[pixelCount];
                bool isTopLeft = (descriptor & 0x20) == 0x20;

                for (int y = 0; y < height; y++)
                {
                    int srcY = isTopLeft ? y : (height - 1 - y);
                    for (int x = 0; x < width; x++)
                    {
                        int srcIdx = (srcY * width + x) * srcBytesPerPixel;
                        int dstIdx = y * width + x;

                        byte r, g, b, a = 255;

                        if (bitsPerPixel == 8) // монохром
                        {
                            byte grey = rawData[srcIdx];
                            r = g = b = grey;
                        }
                        else // 24 или 32 бит (BGR порядок)
                        {
                            b = rawData[srcIdx];
                            g = rawData[srcIdx + 1];
                            r = rawData[srcIdx + 2];
                            if (bitsPerPixel == 32)
                                a = rawData[srcIdx + 3];
                        }

                        pixels[dstIdx] = (a << 24) | (r << 16) | (g << 8) | b;
                    }
                }

                return new TgaTexture(width, height, pixels);
            }
        }

        private static byte[] DecompressRle(BinaryReader reader, int pixelCount, int bytesPerPixel)
        {
            byte[] result = new byte[pixelCount * bytesPerPixel];
            int offset = 0;

            while (offset < result.Length)
            {
                byte header = reader.ReadByte();
                bool isRle = (header & 0x80) != 0;
                int count = (header & 0x7F) + 1;

                if (isRle)
                {
                    byte[] pixel = reader.ReadBytes(bytesPerPixel);
                    for (int i = 0; i < count; i++)
                    {
                        Array.Copy(pixel, 0, result, offset, bytesPerPixel);
                        offset += bytesPerPixel;
                    }
                }
                else
                {
                    int bytesToRead = count * bytesPerPixel;
                    byte[] raw = reader.ReadBytes(bytesToRead);
                    Array.Copy(raw, 0, result, offset, bytesToRead);
                    offset += bytesToRead;
                }
            }
            return result;
        }
    }
}