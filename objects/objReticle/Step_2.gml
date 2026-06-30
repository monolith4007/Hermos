/// @description Attach / Animate
if (not owner.rolling)
{
	instance_destroy();
	exit;
}
x = target.x;
y = target.y;

// Fade in
if (image_alpha < 1) image_alpha = lerp(image_alpha, 1, 0.25);

// Scale down
var limit = 0.8;
if (circle_scale > limit) circle_scale = lerp(circle_scale, limit, 0.75);
if (arrow_scale > limit) arrow_scale = lerp(arrow_scale, limit, 0.75);

// Rotate
direction += 5;