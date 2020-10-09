package jianfengchazhen {
	import flash.display.Sprite;
	import flash.display.GraphicsPathCommand;
	public class Line extends Sprite {

		public function Line(X:int, Y:int, W:int,H:int) {
			x = X;
			y = Y;
            graphics.beginFill(0x000000);
            graphics.drawRect(0,0,W,H);
		}

	}

}