package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.events.CloseEvent;
		
	public class ProductsXMLController extends EventDispatcher
	{
		
		private var productXMLLoader	: ProductXMLLoader = new ProductXMLLoader();
		private var projectsUpdater		: ProjectsUpdater = new ProjectsUpdater();
				
		public function ProductsXMLController()
		{
		}
		
		public function addExistingProductXML():void
		{
			this.productXMLLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADED, onProductXMLLoaded);
			this.productXMLLoader.addEventListener(ProductXMLLoader.USER_CANCELED,	 onProductXMLLoadingCanceled);
			this.productXMLLoader.selectAndLoadXMLFile();
		}
		
		private function onProductXMLLoaded(aEvent:Event):void
		{
			trace ("[ProductsXMLController] onProductXMLLoaded");
			this.productXMLLoader.removeEventListener(ProductXMLLoader.XML_FILE_LOADED, onProductXMLLoaded);
			
			var productXML : XML = new XML(productXMLLoader.xmlFile.data);
			projectsUpdater.addEventListener(ProjectsUpdater.UPDATE_COMPLETED, this.onProjectsDBUpdated);
			projectsUpdater.addEventListener(ProjectsUpdater.UPDATE_CANCELED, this.onProjectsDBUpdateCanceled);
			projectsUpdater.parseXMLData(productXML);			
		}
		
		private function onProjectsDBUpdated(aEvent:Event):void
		{
			projectsUpdater.removeEventListener(ProjectsUpdater.UPDATE_COMPLETED, this.onProjectsDBUpdated);
			this.dispatchEvent(aEvent);
		}
		
		private function onProjectsDBUpdateCanceled(aEvent:Event):void
		{
			projectsUpdater.removeEventListener(ProjectsUpdater.UPDATE_CANCELED, this.onProjectsDBUpdateCanceled);
			this.dispatchEvent(aEvent);
		}
		
		private function onProductXMLLoadingCanceled(aEvent:Event):void
		{
			trace ("[ProductsXMLController] onProductXMLLoadingCanceled");
			this.productXMLLoader.removeEventListener(ProductXMLLoader.USER_CANCELED,	 onProductXMLLoadingCanceled);
			this.dispatchEvent(new Event(ProjectsUpdater.UPDATE_CANCELED));
		} 
		
	}
}