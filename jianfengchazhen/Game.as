package jianfengchazhen {
	import flash.display.MovieClip; 
	import flash.events.Event; 
	import flash.events.MouseEvent; 
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.system.fscommand;
	import flash.net.SharedObject;
	public class Game extends MovieClip {
		var speed: Number;	//小球和“针”旋转的角速度
		var r: int;	//“针”的长度，也就是小球做圆周运动的半径
		var m_centerX: int;
		var m_centerY: int;
		var balls: Array;	//旋转的小球
		var lines: Array;	//旋转的“针”
		var bottom_balls: Array;	//底部的小球
		var m_bottomX: int;
		var m_bottomY: int;
		static var cur_round: int = 1; //当前关数
		const max_round: int = 7;	//最大关数
		const exist_ball_nums: Array = new Array(
			4, 5, 6, 2, 3, 1, 0
		);	//旋转小球的初始数量
		const bottom_ball_nums: Array = new Array(
			6, 8, 10, 18, 20, 22, 24
		);//底部小球的初始数量
		//各种颜色
		const red: int = 0xE60013;
		const pink: int = 0xEB6594;
		const blue: int = 0x00B0CF;
		const orange: int = 0xF2960C;
		const green: int = 0x4DA843;
		const white: int = 0xffffff;
		const yellow: int = 0xE3D434;
		const small_ball_r = 15;	//小球的半径
		const key: int = 1111;	//简单的加密、加密算法的密钥
		public function Game() {
			loadData();
			initMember();
			draw();
		}
		//保存当前关数
		private function saveData() {
			var data: int = cur_round ^ key;	//简单的加密算法
			var so = SharedObject.getLocal("round");
			so.data.round = data;
			so.flush();
		}
		//读取当前关数
		public function loadData() {
			var so = SharedObject.getLocal("round");
			var data = so.data.round;
			if (data != undefined) {
				cur_round = int(data) ^ key;	//简单的解密算法
			} else {
				cur_round = 1;
			}
		}
		//初始化一部分成员变量
		public function initMember() {
			r = 150;
			speed = 4;
			balls = new Array();
			lines = new Array();
			bottom_balls = new Array();
			m_centerX = stage.stageWidth / 2;
			m_centerY = stage.stageHeight / 3;
			//动态更改帧频 　
			stage.frameRate = 30;
			m_bottomX = m_centerX;
			m_bottomY = m_centerY + r + small_ball_r * 2;

		}
		//显示游戏画面
		public function draw() {
			this.stage.color = this.white; //背景色
			var big_ball_r = 50;
			var big_ball: Ball = new Ball(m_centerX, m_centerY, big_ball_r, cur_round + "", 0);
			this.addChild(big_ball);　
			var i: int = 0;
			for (i = 0; i < exist_ball_nums[cur_round - 1]; i++) {
				var angle: Number = i * 360 / exist_ball_nums[cur_round - 1];
				var line: Line;
				line = new Line(m_centerX, m_centerY,this.r,5);
				this.addChild(line);
				this.setChildIndex(line, 0); //设置为第0层
				line.rotation = angle;
				line.addEventListener(Event.ENTER_FRAME, onRotation);
				lines.push(line);
				var ball: Ball;
				ball = new Ball(0, 0, small_ball_r, "", -angle);
				ball.addEventListener(Event.ENTER_FRAME, onMove);
				this.addChild(ball);
				balls.push(ball);
			}
			for (i = 0; i < bottom_ball_nums[cur_round - 1]; i++) {
				var bottom_ball: Ball;
				var Y = m_bottomY + (bottom_ball_nums[cur_round - 1] - i) * 3 * this.small_ball_r;
				bottom_ball = new Ball(m_bottomX, Y, this.small_ball_r, (i + 1) + "", -90);
				this.addChild(bottom_ball);
				bottom_balls.push(bottom_ball);
			}
			this.stage.addEventListener(MouseEvent.CLICK, onLaunch);
		}
		//小球做圆周运动
		public function onMove(e: Event) {
			e.target.m_angle = (e.target.m_angle - speed) % 360;
			var radian = Math.PI / 180 * e.target.m_angle;
			var X = r * Math.cos(radian);
			var Y = r * Math.sin(radian);　　　
			e.target.x = m_centerX + X;
			e.target.y = m_centerY - Y;

		}
		//矩形（“针”）旋转
		public function onRotation(e: Event) {
			e.target.rotation += speed;
		}
		//发射一个底部的小球
		public function onLaunch(e: Event) {

			if (this.bottom_balls.length > 0) {
				var ball = this.bottom_balls.pop();
				ball.addEventListener(Event.ENTER_FRAME, onMoveLine);
				var len = this.bottom_balls.length;
				var i: int = 0;
				//剩下的小球向上移动一个位置
				for (i = len - 1; i > -1; i--) {
					this.bottom_balls[i].y -= this.bottom_balls[i].m_r * 3;
				}
			}
		}
		//发射的小球做向上直线运动
		public function onMoveLine(e: Event) {
			e.target.y -= speed * 4;
			if (e.target.y <= this.m_centerY + this.r) {
				//取消向上直线运动
				e.target.removeEventListener(Event.ENTER_FRAME, onMoveLine);
				//开始圆周运动
				e.target.addEventListener(Event.ENTER_FRAME, onMove);
				this.balls.push(e.target);
				//添加矩形（“针”）
				var line: Line;
				line = new Line(m_centerX, m_centerY,this.r,5);
				this.addChild(line);
				this.setChildIndex(line, 0); //设置为第0层
				line.rotation = 90;
				line.addEventListener(Event.ENTER_FRAME, onRotation);
				this.lines.push(line);
				//判断是否相撞
				var len = this.balls.length;
				var i: int = 0;
				for (i = len - 2; i > -1; i--) {
					var distance = distanceOf2points(e.target.x, e.target.y,
						this.balls[i].x, this.balls[i].y);
					if (distance < e.target.m_r + this.balls[i].m_r) {
						//相撞，游戏失败
						gameLose();
						return;
					}

				}
				if (this.bottom_balls.length == 0) {
					//游戏过关
					gameWin();
				}
			}

		}
		//游戏暂停
		public function gameStop() {
			//禁止发射小球
			this.stage.removeEventListener(MouseEvent.CLICK, onLaunch);
			var len = this.balls.length;
			var i: int = 0;
			//小球和矩形（“针”）停止运动
			for (i = len - 1; i > -1; i--) {
				this.balls[i].removeEventListener(Event.ENTER_FRAME, onMove);
				this.lines[i].removeEventListener(Event.ENTER_FRAME, onRotation);
			}
		}
		//游戏失败
		public function gameLose() {
			//背景色更改红色
			this.stage.color = this.red;
			gameStop();
			//显示按钮
			var W = 150,
				H = 50;
			var X = this.m_centerX - W / 2,
				Y = this.m_centerY - H / 2;
			this.addButton(X, Y + H * 3 / 2, "重玩本关", this.blue, W, H, onPlayAgain);
			this.addButton(X, Y + H * 6 / 2, "重置游戏", this.yellow, W, H, onReset);
			this.addButton(X, Y + H * 9 / 2, "退出游戏", this.orange, W, H, onExit);
		}
		//游戏成功
		public function gameWin() {
			//背景色更改绿色
			this.stage.color = this.green;
			gameStop();
			//显示按钮
			var W = 150,
				H = 50;
			var X = this.m_centerX - W / 2,
				Y = this.m_centerY - H / 2;
			if (cur_round < this.max_round) {
				this.addButton(X, Y, "下一关", this.pink, W, H, onNextRound);
			}
			this.addButton(X, Y + H * 3 / 2, "重玩本关", this.blue, W, H, onPlayAgain);
			this.addButton(X, Y + H * 6 / 2, "重置游戏", this.yellow, W, H, onReset);
			this.addButton(X, Y + H * 9 / 2, "退出游戏", this.orange, W, H, onExit);
		}
		//显示按钮
		public function addButton(X: int, Y: int, text: String, color: int, W: int, H: int, listener: Function) {
			var button = new MyButton(X, Y, text, color, W, H);
			button.addEventListener(MouseEvent.CLICK, listener);
			this.addChild(button);
		}
		//计算两点之间的距离
		public function distanceOf2points(x1: Number, y1: Number, x2: Number, y2: Number): Number {
			return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
		}
		//退出游戏
		public function onExit(e: MouseEvent) {
			saveData();
			//测试和调试的时候不起作用，单独点击运行.swf文件时才能关闭窗口
			fscommand("quit", "true");
		}
		//重玩本关
		public function onPlayAgain(e: MouseEvent) {
			//拦截鼠标点击
			e.stopPropagation();
			//移除所有child
			this.removeChildren();
			initMember();
			draw();
			trace("onPlayAgain");
		}
		//下一关
		public function onNextRound(e: MouseEvent) {
			trace("onNextRound");
			cur_round++;
			if (cur_round <= this.max_round){
				saveData();
				onPlayAgain(e);
			}
		}
		//重置游戏
		public function onReset(e: MouseEvent) {
			cur_round = 1;
			saveData();
			onPlayAgain(e);
		}

	}

}