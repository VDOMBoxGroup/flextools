package vdom.connection.utils
{

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import mx.controls.Image;
import mx.utils.Base64Decoder;

public class Extract extends EventDispatcher
{
	private var bs : Base64Decoder = new Base64Decoder();

	private var base64Zip : String = "eJzrDPBz5+WS4mJgYOD19HAJAtIKQCzKwQQkV6yv3gukWNIdfR0ZGNafMGftegnkS5a4RpQE56eVlCcWpTI4puQnpSp45iampwalJqZUFp5MtQEqMvZ0cQypuJVUIiCQsEA14c/5AwZZB1ewKt9lmsa55Rsjt7HxYQ0J1sUJHcxuzMzMs6IYBBIY+Bo5J9VNMSgGamfwdPVzWeeU0AQAXHMuLw==";
	private var ld : Loader = new Loader();
	private var ba : ByteArray = new ByteArray;
	private var img : Image = new Image();

	public function Extract() : void
	{

	}

	;

	public function unziping( base64Zip : String = '' ) : void
	{

		if ( base64Zip == '' ) this.base64Zip = base64Zip;
		bs.decode( base64Zip );

		ba = bs.drain();
		//	ba.uncompress();
		//	trace('*****  Разпаковка  *******')
		//ld ;
		var zzz : Object = ba;
		ld.loadBytes( ba );
		ld.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
	}

	private function loadComplete( evt : Event ) : void
	{

		img.width = ld.width;
		img.height = ld.height;
		img.source = ld.content;
		//addChild(img);
		dispatchEvent( new UtilsEvent( UtilsEvent.UNZIP_COMPLETE, ld.content ) );
		ld.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
	}

	public function getImage() : DisplayObject
	{
		//		trace ("img Extract2: "+ img.width);
		return  ld.content;
	}

}
}
/*
 import com.connection.utils.Extract;
 import com.connection.soap.SoapEvent;

 private var extract:Extract = new Extract();

 private function init(){
 extract.unziping();
 extract.addEventListener(GET_ECHO_UNZIP_OK, getImage);
 }

 private function getImage(evt:Event):void{

 //necessary data for as
 myImage = extract.getImage()
 }
 */