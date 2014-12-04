/**
 * plugin.js
 *
 * Copyright 2013, Da Zhao
 * Released under MIT License.
 *
 * License: https://github.com/zhaoda/tinymce-upload/blob/master/LICENSE.md
 * Contributing: https://me.alipay.com/sage6437
 */

tinymce.PluginManager.add('upload', function(editor) {
	var DOM = tinymce.DOM,
		doc = document,
		container = editor.getContainer(),
		buttonIcon,
		formAction = editor.settings.upload_action || 'upload.php', //tinymce.init({upload_action: 'upload.php'})
		formFileName = editor.settings.upload_file_name || 'userfile', //tinymce.init({upload_file_name: 'userfile'})
		upload,
		isInit = false

	//Upload Class
	function Upload(icon) {
		this.icon = icon
		this.button = DOM.getParents(this.icon, '.mce-btn')[0]
		this.uid = DOM.uniqueId()
		this.createControl()
	}

	Upload.prototype = {
		//create control
		createControl: function() {
			var self = this,
				iframeId = self.uid + '_iframe',
				editorName = self.uid + '_editor',
				html = '<form action="' + formAction + '" target="' + iframeId + '" method="post" accept-charset="utf-8" enctype="multipart/form-data">\
<input type="file" name="' + formFileName + '" value="" />\
<input type="hidden" name="editor" value="' + editorName + '" />\
</form>\
<iframe id="' +iframeId + '" name="' +iframeId + '"></iframe>'

			//register a global variable of the editor
			window[editorName] = editor

			//create the control container element
			var con = self.con = DOM.create('div', {id: self.uid}, html)

			//set styles of the container
			var buttonRect = DOM.getRect(self.button)
			DOM.setStyle(con, {
				width: buttonRect.w,
				height: buttonRect.h,
				opacity: 0,
				overflow: 'hidden',
				margin: 0,
				padding: 0,
				position: 'absolute'
			})

			DOM.insertAfter(con, doc.body)

			//the form element
			self.form = DOM.select('form', con)[0]

			//the file type input element
			self.input = DOM.select('input', con)[0]
			DOM.setStyle(self.input, {
				width: buttonRect.w,
				height: buttonRect.h
			})

			DOM.bind(self.input, 'change', function() {
				DOM.hide(con)
				DOM.addClass(self.icon, 'mce-i-upload-disabled')
				self.form.submit()
			})

			//adjust the position of the container
			self.adjustPos()
			var timer,
				adjustPos = function() {
					timer && clearTimeout(timer)
					timer = setTimeout(function() {
						self.adjustPos()
					}, 200)
				}
			DOM.bind(window, 'resize', adjustPos)
			DOM.bind(window, 'scroll', adjustPos)
			DOM.bind(doc.body, 'scroll', adjustPos)
			DOM.bind(doc.documentElement, 'scroll', adjustPos)
		},
		//adjust the position of the control
		adjustPos: function() {
			var self = this,
				buttonPos = DOM.getPos(self.button, doc.body)

			DOM.setStyle(self.con, {
				left: buttonPos.x,
				top: buttonPos.y
			})
		},
		//after uploading callback
		finish: function() {
			var self = this
			DOM.removeClass(self.icon, 'mce-i-upload-disabled')
			DOM.show(self.con)
			self.adjustPos()
		}
	}

	//when the editor is initialised
	editor.on('init', function() {
		//find the button icon element
		buttonIcon = DOM.select('.mce-i-upload', container)[0]
	})

	//add button
	editor.addButton('upload', {
		icon: 'upload',
		tooltip: 'Upload',
		onmouseover: function() {
			//Initialized only once
			if(!isInit && buttonIcon) {
				isInit = true
				upload = new Upload(buttonIcon)
			}
		}
	})

	return {
		finish: function() {
			upload.finish()
		}
	}
})