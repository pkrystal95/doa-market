-- Update product thumbnails with placeholder images
UPDATE products SET thumbnail = 'https://picsum.photos/seed/' || id || '/400/400' WHERE thumbnail IS NULL;
