package res.input;

enum ControllerEvent {
	BUTTON_DOWN(controller:Controller, button:ControllerButton);
	BUTTON_UP(controller:Controller, button:ControllerButton);
	CONNECTED(controller:Controller);
	DISCONNECTED(controller:Controller);
}
