package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import spinnerFolder.SpinnerPopUpManager;
	import spinnerFolder.SpinnerPopupMessages;
	
	public class ProductsUpdator extends EventDispatcher
	{
		private var productUpdator			: ProductUpdator = new ProductUpdator();
		
		private var selectedProducts : ArrayCollection = new ArrayCollection();
		
		private var currentProductIndex : Number = 0;
		
		private var spinnerManager : SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		
		public function ProductsUpdator()
		{
		}
		
		public function updateProducts(aProducts : ArrayCollection) : void
		{
			if (!aProducts || aProducts.length == 0)
			{
				this.dispatchEvent(new ProductsUpdatorEvent(ProductsUpdatorEvent.UPDATE_PRODUCTS_SELECTION_ERROR));
				return;
			}
			
			getSelectedProducts(aProducts);
			
			if (!selectedProducts || selectedProducts.length == 0)
			{
				this.dispatchEvent(new ProductsUpdatorEvent(ProductsUpdatorEvent.UPDATE_PRODUCTS_SELECTION_ERROR));
				return;
			}
			
			spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
			spinnerManager.showSpinner();
			
		}
		
		private function onSpinnerAdded(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
		
			currentProductIndex = 0;
			updateNextProduct();
		}
		
		private function getSelectedProducts(aProducts : ArrayCollection) : void
		{
			for(var name:String in aProducts)
			{
				if ( aProducts[name]["chBox"]["selected"] )
					selectedProducts.addItem(aProducts[name]);
			}
		}
		
		private function updateNextProduct():void
		{
			if (currentProductIndex >= selectedProducts.length)
			{
				onLastProductUpdated();
				return;
			}
			
			var product : Object = selectedProducts.getItemAt(currentProductIndex);
			
			productUpdator.addEventListener(ProductsUpdatorEvent.UPDATE_COMPLETE, productUpdateHandler);
			productUpdator.addEventListener(ProductsUpdatorEvent.UPDATE_ERROR, productUpdateHandler);
			productUpdator.addEventListener(ProductsUpdatorEvent.UPDATE_NOT_REQUIED, productUpdateHandler);
			
			if (!product["xmlContent"])
				productUpdator.load(product["url"], product["title"]);
			else
				productUpdator.parseData(product["xmlContent"]);
		}
		
		private function productUpdateHandler(evt:ProductsUpdatorEvent):void
		{
			productUpdator.removeEventListener(ProductsUpdatorEvent.UPDATE_COMPLETE, productUpdateHandler);
			productUpdator.removeEventListener(ProductsUpdatorEvent.UPDATE_ERROR, productUpdateHandler);
			productUpdator.removeEventListener(ProductsUpdatorEvent.UPDATE_NOT_REQUIED, productUpdateHandler);
			
			switch(evt.type)
			{
				case ProductsUpdatorEvent.UPDATE_COMPLETE:
				{
					trace ("productUpdateHandler : UPDATE_COMPLETE");
					break;
				}
					
				case ProductsUpdatorEvent.UPDATE_NOT_REQUIED:
				{
					trace ("productUpdateHandler : UPDATE_NOT_REQUIED");
					break;
				}
					
				case ProductsUpdatorEvent.UPDATE_ERROR:
				{
					trace ("productUpdateHandler : UPDATE_ERROR");
					break;
				}
				
			}
			
			onProductUpdated();
		}
		
		private function onProductUpdated():void
		{
			currentProductIndex ++;
			
			updateNextProduct();
		}
		
		private function onLastProductUpdated():void
		{
			spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCTS_UPDATION_COMPLETE);
			
			spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
			setTimeout(spinnerManager.hideSpinner, 400);
			
		}
		
		private function spinnerHideHandler(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
			
			currentProductIndex = 0;
			selectedProducts.removeAll();
			
			this.dispatchEvent(new ProductsUpdatorEvent(ProductsUpdatorEvent.UPDATE_COMPLETE));
		}
		
	}
	
	
}