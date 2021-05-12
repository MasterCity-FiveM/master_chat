var AutoCompleteOptions = {
	data: [],
	getValue: "name",

	template: {
		type: "description",
		fields: {
			description: "help"
		}
	},
	minCharNumber: 3,
	list: {
		match: {
			enabled: true
		},
		maxNumberOfElements: 2,
		sort: {
			enabled: true
		},
		showAnimation: {
			type: "fade",
			time: 400,
			callback: function() {}
		},	

		hideAnimation: {
			type: "slide",
			time: 400,
			callback: function() {}
		}
	}
};

var server_suggestions = false;
var store = {

    keyCount:0,
    commandCount:0,
    prevCommand:[],
    put : function(val) {        
        this.commandCount++;
        this.keyCount = this.commandCount;
        this.prevCommand.push(val);        
    },
    get : function() {
        this.keyCount--;
        if(typeof this.prevCommand[this.keyCount] !== "undefined") {
            return this.prevCommand[this.keyCount];
        }    
    }    

}

$(document).ready(function () {
	window.addEventListener("message", function (event) {
		if (event.data.action == "show") {
			$(".ui").show();
			$("#message").val("");
			$("#message").focus();
			$('.box100').scrollTop($('.box100')[0].scrollHeight);
			if (server_suggestions == false) {
				$.post("https://master_chat/GetSuggestions", JSON.stringify({}));
				server_suggestions = true;
			}
			window.scrollTo(0,document.body.scrollHeight);
		} else if (event.data.action == "hide") {
			closeUI();
		} else if (event.data.action == "suggestions") {
			Sugs = event.data.suggestions;
			for (var prop in Sugs) {
				AutoCompleteOptions.data.push({name: Sugs[prop].name, help: Sugs[prop].help});
			}
		} else if (event.data.action == "sent_message") {
			$(".box100").append('<div class="sent amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');

			///CLEANUP
			$('.box100').scrollTop($('.box100')[0].scrollHeight);
		} else if (event.data.action == "receive_message") {
			if (event.data.message_type == 'local') {
				$(".box100").append('<div class="chat amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');
			}else if (event.data.message_type == 'error') {
				$(".box100").append('<div class="chat error amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');
			}else if (event.data.message_type == 'info') {
				$(".box100").append('<div class="chat info amessage"><p class="name">' + htmlEntities(event.data.name) + ':</p><p>' + htmlEntities(event.data.message) + '</p></div><div style="clear:both;"></div>');
			}
			
			///CLEANUP
			$('.box100').scrollTop($('.box100')[0].scrollHeight);
		}
	});
	
	function closeUI() {
		$(".ui").hide();
	}
	
	document.onkeydown = function(evt) {
		evt = evt || window.event;
		var isEscape = false;
		
		if ("key" in evt) {
			isEscape = (evt.key === "Escape" || evt.key === "Esc");
		} else {
			isEscape = (evt.keyCode === 27);
		}
		
		if (isEscape) {
			$.post("https://master_chat/closeUI", JSON.stringify({}));
		}
	};
	
	$("#message").on('keydown', function (e) {
		if (e.key === 'Enter' || e.keyCode === 13) {
			var msg = $("#message").val();
			if(msg === "" || msg === " ") {
				$.post("https://master_chat/closeUI", JSON.stringify({}));
				return;
			}
			$(this).val("");
			store.put(msg)
			$.post("https://master_chat/sentMessage", JSON.stringify({message:msg}));
		}
	});
	
	$("#message").on('keydown', function (e) {
		if (e.keyCode === 38) {
			$(this).val(store.get());
		}
	});

	function htmlEntities(str) {
		return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
	}
	
	$(".basicAutoComplete").easyAutocomplete(AutoCompleteOptions);
});
