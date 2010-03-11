var TinyMCE_AdvancedTheme = {

	getEditorTemplate : function(settings, editorId) {
		var html = "";

		// Build toolbar and editor instance
		html += "..";

		return {
			html : html,
			delta_width : 0,
			delta_height : 0
		};

	},

	initInstance : function(inst) {

		inst.addShortcut('ctrl', 'k', 'lang_link_desc', 'mceLink');
	},

	removeInstance : function(inst) {
		
	},

	hideInstance : function(inst) {
		
	},
	
	_insertImage : function(src, alt, border, hspace, vspace, width, height, align, title, onmouseover, onmouseout) {
		tinyMCE.execCommand("mceInsertContent", false, tinyMCE.createTagHTML('img', {
			src : tinyMCE.convertRelativeToAbsoluteURL(tinyMCE.settings['base_href'], src), // Force absolute
			mce_src : src,
			alt : alt,
			border : border,
			hspace : hspace,
			vspace : vspace,
			width : width,
			height : height,
			align : align,
			title : title,
			onmouseover : onmouseover,
			onmouseout : onmouseout
		}));
	},

	_insertLink : function(href, target, title, onclick, style_class) {
		
		tinyMCE.execCommand('mceBeginUndoLevel');
		
		if (tinyMCE.selectedInstance && tinyMCE.selectedElement && tinyMCE.selectedElement.nodeName.toLowerCase() == "img") {
			var doc = tinyMCE.selectedInstance.getDoc();
			var linkElement = tinyMCE.getParentElement(tinyMCE.selectedElement, "a");
			var newLink = false;

			if (!linkElement) {
				linkElement = doc.createElement("a");
				newLink = true;
			}

			var mhref = href;
			
			var thref = tinyMCE.convertURL(href, linkElement);
			mhref = tinyMCE.getParam('convert_urls') ? href : mhref;

			tinyMCE.setAttrib(linkElement, 'href', thref);
			tinyMCE.setAttrib(linkElement, 'mce_href', mhref);
			tinyMCE.setAttrib(linkElement, 'target', target);
			tinyMCE.setAttrib(linkElement, 'title', title);
			tinyMCE.setAttrib(linkElement, 'onclick', onclick);
			tinyMCE.setAttrib(linkElement, 'class', style_class);

			if (newLink) {
				linkElement.appendChild(tinyMCE.selectedElement.cloneNode(true));
				tinyMCE.selectedElement.parentNode.replaceChild(linkElement, tinyMCE.selectedElement);
			}
			
			return;
		}

		if (!tinyMCE.linkElement && tinyMCE.selectedInstance) {
			
			if(!tinyMCE.selectedInstance.selection.getSelectedHTML())
				return
				
			if (tinyMCE.isSafari) {
				tinyMCE.execCommand("mceInsertContent", false, '<a href="' + tinyMCE.uniqueURL + '">' + tinyMCE.selectedInstance.selection.getSelectedHTML() + '</a>');
			} else
				tinyMCE.selectedInstance.contentDocument.execCommand("createlink", false, tinyMCE.uniqueURL);
			
			tinyMCE.linkElement = tinyMCE.getElementByAttributeValue(tinyMCE.selectedInstance.contentDocument.body, "a", "href", tinyMCE.uniqueURL);

			var elementArray = tinyMCE.getElementsByAttributeValue(tinyMCE.selectedInstance.contentDocument.body, "a", "href", tinyMCE.uniqueURL);

			for (var i=0; i<elementArray.length; i++) {
				var mhref = href;
				var thref = tinyMCE.convertURL(href, elementArray[i]);
				mhref = tinyMCE.getParam('convert_urls') ? href : mhref;

				tinyMCE.setAttrib(elementArray[i], 'href', thref);
				tinyMCE.setAttrib(elementArray[i], 'mce_href', mhref);
				tinyMCE.setAttrib(elementArray[i], 'target', target);
				tinyMCE.setAttrib(elementArray[i], 'title', title);
				tinyMCE.setAttrib(elementArray[i], 'onclick', onclick);
				tinyMCE.setAttrib(elementArray[i], 'class', style_class);
			}

			tinyMCE.linkElement = elementArray[0];
		}

		if (tinyMCE.linkElement) {
			var mhref = href;
			href = tinyMCE.convertURL(href, tinyMCE.linkElement);
			mhref = tinyMCE.getParam('convert_urls') ? href : mhref;

			tinyMCE.setAttrib(tinyMCE.linkElement, 'href', href);
			tinyMCE.setAttrib(tinyMCE.linkElement, 'mce_href', mhref);
			tinyMCE.setAttrib(tinyMCE.linkElement, 'target', target);
			tinyMCE.setAttrib(tinyMCE.linkElement, 'title', title);
			tinyMCE.setAttrib(tinyMCE.linkElement, 'onclick', onclick);
			tinyMCE.setAttrib(tinyMCE.linkElement, 'class', style_class);
		}

		tinyMCE.execCommand('mceEndUndoLevel');
	}
};

tinyMCE.addTheme("advanced", TinyMCE_AdvancedTheme);
