package
{
	public class AlertMessages
	{
		public static const MSG_TYPE_ERROR		: String = "Error:";
		public static const MSG_TYPE_WARNING	: String = "Warning:";
		
		public static const MSG_PRODUCT_EXISTS_IN_UPDATE_LIST	: String = "This product already exists in update list.\nReplace this product?";
		public static const MSG_INCORRECT_XML_FORMAT			: String = "Incorrect format of loaded xml.";
		public static const MSG_ERROR_ON_LOAD_XML				: String = "Error during xml loading.";
		
		public static const MSG_PRODUCTS_UPDATE_ERROR			: String = "Error during products updating.";
		public static const MSG_PRODUCTS_UPDATE_SELECTED_ERROR	: String = "No selected products.";
		
		public static const TEMPLATE_EXISTING_PRODUCT_VERSION	: String = "EXIST_VERSION";
		public static const TEMPLATE_NEW_PRODUCT_VERSION		: String = "NEW_VERSION";
		
		public static const MSG_BOOKMARK_ADDED					: String = "Bookmark added.";
		public static const MSG_BOOKMARK_ALREADY_EXISTS			: String = "Boockmark already exists.";
		
		public function AlertMessages()
		{
		}
	}
}