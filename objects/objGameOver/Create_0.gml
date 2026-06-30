/// @description Initialize
image_speed = 0;
image_index = lives > 0; // 0 = "GAME", 1 = "TIME"
offset = 256 + CAMERA_WIDTH * 0.5;
audio_enqueue_bgm(bgmGameOver, 3);