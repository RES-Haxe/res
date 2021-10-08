package res.platforms.java;

import java.awt.Dimension;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.javax.swing.JFrame;
import java.javax.swing.JPanel;
import java.lang.Runnable;
import java.lang.Thread;
import res.types.RESConfig;

class JavaRESApp implements Runnable implements KeyListener {
	public final res:RES;

	final frame:JFrame;
	final pannel:JPanel;
	final windowWidth:Int;
	final windowHeight:Int;

	public function new(resConfig:RESConfig, ?scale:Int = 3, ?windowTitle:String = 'RES Java') {
		res = RES.boot(JavaPlatform, resConfig);

		windowWidth = res.width * scale;
		windowHeight = res.height * scale;

		frame = new JFrame(windowTitle);
		frame.setResizable(false);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		pannel = new JPanel();
		pannel.setPreferredSize(new Dimension(windowWidth, windowHeight));

		frame.add(pannel);
		frame.pack();
		frame.setVisible(true);
		frame.addKeyListener(this);
	}

	public function run() {
		while (true) {
			res.update(1 / 60);
			res.render();

			final img = cast(res.platform.frameBuffer, FrameBuffer).bufferedImage;

			pannel.getGraphics().drawImage(img, 0, 0, windowWidth, windowHeight, null);

			Thread.sleep(1000 / 60);
		}
	}

	public function keyPressed(param1:KeyEvent) {
		res.keyboard.keyDown(param1.getKeyCode());
	}

	public function keyReleased(param1:KeyEvent) {
		res.keyboard.keyUp(param1.getKeyCode());
	}

	public function keyTyped(param1:KeyEvent) {
		final char:Int = cast param1.getKeyChar();

		if (char >= 96)
			res.keyboard.keyPress(char);
	}
}
