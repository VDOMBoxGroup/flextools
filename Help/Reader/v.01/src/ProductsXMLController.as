package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.events.CloseEvent;
		
	public class ProductsXMLController extends EventDispatcher
	{
		
		private var productXMLLoader	: ProductXMLLoader = new ProductXMLLoader();
		private var _productXML 		: XML;
		
		public function ProductsXMLController()
		{
		}
		
		public function get productXML():XML
		{
			return _productXML;
		}

		public function set productXML(value:XML):void
		{
			_productXML = value;
		}

		public function addExistingProductXML():void
		{
			this.productXMLLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADED, 			onProductXMLLoaded);
			this.productXMLLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADING_STARTED,	onProductXMLLoadingStarted);
			this.productXMLLoader.addEventListener(ProductXMLLoader.USER_CANCELED,				onProductXMLLoadingCanceled);
			this.productXMLLoader.selectAndLoadXMLFile();
		}
		
		private function onProductXMLLoaded(aEvent:Event):void
		{
			this.productXMLLoader.removeEventListener(ProductXMLLoader.XML_FILE_LOADED, onProductXMLLoaded);
			
			productXML = new XML(productXMLLoader.xmlFile.data);
			
			this.dispatchEvent(aEvent);
		}
		
		private function onProductXMLLoadingCanceled(aEvent:Event):void
		{
			this.productXMLLoader.removeEventListener(ProductXMLLoader.USER_CANCELED,	 onProductXMLLoadingCanceled);
			this.dispatchEvent(aEvent);
		} 
		
		private function onProductXMLLoadingStarted(aEvent:Event):void
		{
			this.productXMLLoader.removeEventListener(ProductXMLLoader.XML_FILE_LOADING_STARTED,	onProductXMLLoadingStarted);
			this.dispatchEvent(aEvent);
		}
		
	}
}