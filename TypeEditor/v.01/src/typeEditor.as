// ActionScript file
import mx.events.MenuEvent;
import mx.core.Application;


private function mainMenuHandler(mEvent:MenuEvent):void {
	
	switch (String(mEvent.item.@data)) {
		
		case "new":
			break;
		
		case "open":
			break;
		
		case "save":
			break;
		
		case "close":
			Application.application.close();
			break;
	}
}

