package vdom.components.edit.containers.workAreaClasses {

import mx.controls.Image;
import flash.display.Bitmap;

public class WysiwygImage extends Image {
	
	public function WysiwygImage() {
		
		super();
	}
	
	/* public function set resource(base64Data:String):void {
		
		var decoder:Base64Decoder = new Base64Decoder();
		decoder.decode(resource);
		
		var imageSource:ByteArray = decoder.drain();
		imageSource.uncompress();
		
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
		loader.name = resourceID;
		loader.loadBytes(imageSource);
	}
	
	public function get resource():String{
		
		return String('');
	} */
}
}