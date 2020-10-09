package jianfengchazhen {
	import fl.controls.Button;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	public class MyButton extends Button {

		public function MyButton(X: int, Y: int, text: String,
			color: int, W: int, H: int) {
			this.x = X;
			this.y = Y;
			var tfor: TextFormat = new TextFormat();
			tfor.size = 24; //文字大小
			tfor.color = 0xffffff; //文字颜色
			this.label = text;
			this.setStyle("textFormat", tfor);
			this.graphics.beginFill(color);
			this.width = W;
			this.height = H;
			var sp: Sprite = new Sprite();
			sp.graphics.beginFill(color);
			sp.graphics.drawRect(0, 0, W, H);
			this.addChild(sp);
			this.setChildIndex(sp, 0);
		}

	}

}