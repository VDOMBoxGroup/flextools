package
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	
	import mx.controls.Alert;

	public class ClipboardManager
	{
		private static var instance : ClipboardManager;
	
		private var resourceImageUtils	: ResourceUtils = ResourceUtils.getInstance();
		
		private var wysiwygImage		: WysiwygImage; 
		
		public function ClipboardManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );
		}
		
		public static function getInstance() : ClipboardManager
		{
			if ( !instance )
			{
				instance = new ClipboardManager();
			}
			
			return instance;
		}
		
		
		private function get clipboard() : Clipboard
		{
			return Clipboard.generalClipboard;
		}
		
		private function get isBitmapFormat() : Boolean
		{
			return clipboard.getData(ClipboardFormats.BITMAP_FORMAT);
		}
		
		private function get isHTMLFormat() : Boolean
		{
			return clipboard.getData(ClipboardFormats.HTML_FORMAT);
		}
		
		private function get isFileListFormat() : Boolean
		{
			return clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT);
		}
		
		public function getImageFromClipboard() : WysiwygImage
		{
			wysiwygImage = new WysiwygImage();
			
			if (isBitmapFormat)
			{
				getImageFromBitmapFormat();
			} 
			else if (isHTMLFormat)
			{
				getImageFromHTMLFormat();
			} 
			else if (isFileListFormat)
			{
				getImageFromFileFormat();
			} else 
			{
				showAlertNoImages();
			}
			
			return wysiwygImage;
		}
		
		private function getImageFromBitmapFormat() : void
		{
			try {
				var sourceBitmapData : BitmapData = clipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
			} catch (e:Error)
			{
				return;
			}
			
			if (!sourceBitmapData)
				return;
			
			var imageFile : File = resourceImageUtils.createResourceFromBitmapData(sourceBitmapData);
			
			if (ResourceUtils.fileExists(imageFile))
				wysiwygImage.src = imageFile.url; 
		}
		
		private function parseHTMLFormat () : void
		{
			var sourceStr : String = clipboard.getData(ClipboardFormats.HTML_FORMAT).toString().toLowerCase();
			
			var regExpImgTeg	: RegExp = /<[ ]*img[^<]*[\/]{0,1}>/;
			var regExpSrc		: RegExp = /src[ ]*=[ ]*"[^"]*"/;
			var regExpWidth		: RegExp = /width[ ]*=[ ]*["]{0,1}[\d]+/;
			var regExpHeight	: RegExp = /height[ ]*=[ ]*["]{0,1}[\d]+/;
			var regExpDigitVal	: RegExp = /[\d]+/i;
			
			var matchedImages : Array = sourceStr.match(regExpImgTeg);
			
			if (!matchedImages || matchedImages.length == 0)
				return;
			
			var img : String = matchedImages[0];
			
			var imgSrc : String;
			var imgWidth : String;
			var imgHeight : String;
			
			try {
				imgSrc = img.match(regExpSrc)[0];
				
				var indexFirstQuote : int = imgSrc.indexOf("\"");
				var indexLastQuote : int = imgSrc.lastIndexOf("\"");
				
				wysiwygImage.src = imgSrc.substring(indexFirstQuote+1, indexLastQuote);
			} catch (e:Error)
			{
			}
			
			try {
				imgWidth = img.match(regExpWidth)[0];
				
				wysiwygImage.width = Utils.getSizeFromStyle(imgWidth, Utils.TYPE_WIDTH);
			} catch (e:Error)
			{
			}
			
			try {
				imgHeight = img.match(regExpHeight)[0];
				
				wysiwygImage.height = Utils.getSizeFromStyle(imgHeight, Utils.TYPE_HEIGHT);
			} catch (e:Error)
			{
			}
			
		}
		
		private function isHTTPImage(imgURL : String) : Boolean
		{
			return imgURL.indexOf("http://") >= 0 || imgURL.indexOf("https://") >= 0;
		}
		
		
		private function getImageFromHTMLFormat() : void
		{
			var imgSrcSource : String = "";
			var imgSrcTarget : String = "";
			
			parseHTMLFormat();
			
			if (!wysiwygImage.src)
			{
				showAlertNoImages();
				return;
			}
			
			imgSrcSource = imgSrcTarget = wysiwygImage.src;
			
			if ( isHTTPImage(imgSrcSource) )
			{
				imgSrcTarget = resourceImageUtils.loadHttpImg(imgSrcSource);
			} else 
			{
				imgSrcTarget = resourceImageUtils.copyImg(imgSrcSource);
			}
			
			wysiwygImage.src = imgSrcTarget;
		}
		
		private function getImageFromFileFormat() : void
		{
			var imgTargetSrc : String;
			
			for each (var file : File in clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT))
			{
				if (ResourceUtils.fileExists(file) && ResourceFileTypes.isImageFile(file))
				{
					imgTargetSrc = resourceImageUtils.copyImg(file.url);
					break;
				}
			}
			
			if (imgTargetSrc)
				wysiwygImage.src = imgTargetSrc;
			else 
				showAlertNoImages();
		}
		
		private function showAlertNoImages():void
		{
			Alert.show(AlertMessages.MSG_CLIPBOARD_HAS_NO_IMAGES, AlertMessages.MSG_TYPE_ERROR);
		}
		
	}
}