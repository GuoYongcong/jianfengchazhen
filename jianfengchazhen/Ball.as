package jianfengchazhen {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class Ball extends Sprite {
		public var m_r: int;
		public var m_text: TextField;
		public var m_angle: int;
		public function Ball(X: int, Y: int, R: int, text: String, angle: int) {
			x = X;
			y = Y;
			m_angle = angle;
			m_r = R;
			var tfor: TextFormat = new TextFormat();
			tfor.size = R; //文字大小
			tfor.color = 0xffffff; //文字颜色：白色
			m_text = new TextField();
			m_text.defaultTextFormat = tfor;
			m_text.x = -R / 3;
			if (text != "" && int(text) > 9)
				m_text.x = -R * 5 / 8;
			m_text.y = -R * 7 / 12;
			m_text.height = R * 2;
			m_text.width = R * 2;
			m_text.text = text;
			this.addChild(m_text);
			this.graphics.beginFill(0x000000);
			this.graphics.drawCircle(0, 0, m_r);
			this.graphics.endFill();
		}


	}

}