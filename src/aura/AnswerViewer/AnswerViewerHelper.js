({
  //successfully component created dynamically,that component set to div's body
  //
  setImageSrc: function(cmp, helper, answerOptionsId, attachment, answer) {

    window.setTimeout($A.getCallback(function() {
      if (cmp.isValid()) {
        var uiCmps = [];
        var imageSrc = [];
        var k = 0;
        for (var i = 0; i < answerOptionsId.length; i++) {

          if (attachment[k] && answerOptionsId[i] === attachment[k].ParentId) {
            imageSrc.push(attachment[k].Id);
            k++;
          } else {
            imageSrc.push(null);
          }

        }
        cmp.set("v.imageSrc", imageSrc);
        cmp.set("v.hasQuestionsQueried", true);
        helper.createImage(cmp, imageSrc, answer, uiCmps);
      }
    }), 0);

  },
  setImageSrcByQuestion: function(cmp, helper, answer, attachment) {

    window.setTimeout($A.getCallback(function() {
      if (cmp.isValid()) {
        var uiCmps = [];
        var imageSrc = [];
        var k = 0;
        for (var i = 1; i <= answer.length; i++) {
          if (attachment[k] && parseInt(attachment[k].Name) === i) {
            imageSrc.push(attachment[k].Id);
            k++;
          } else if(!attachment[k] || attachment[k] && attachment[k].Name != 'Question-Image'){
            imageSrc.push(null);
          }

        }
        cmp.set("v.imageSrc", imageSrc);

        cmp.set("v.hasQuestionsQueried", true);
        helper.createImage(cmp, imageSrc, answer, uiCmps);
      }
    }), 0);

  },
  createUiCmps: function(cmp, uiCmps) {
	var self = this;
    var div1 = cmp.find("createUiCmp");
    div1.set("v.body", []);
    $A.createComponents(uiCmps,
      function(components, status, errorMessage) {

        if (cmp.isValid() && status === "SUCCESS") {
          div1.set("v.body", components);
        } else if (cmp.isValid() && status === "INCOMPLETE") {
          errorMessage = "No response from server or client is offline";
          self.showNotificationEvt('error', errorMessage, null);
        } else if (cmp.isValid() && status === "ERROR") {
          self.showNotificationEvt('error', errorMessage, null);
        }
      }
    );
  },
  craeteUiCmpsByImage: function(cmp, uiCmps) {
    var self = this;
    var div1 = cmp.find("createUiCmp");
    div1.set("v.body", []);
    $A.createComponents(uiCmps,
      function(components, status, errorMessage) {
        var div1Body = div1.get("v.body");
        if (cmp.isValid() && status === "SUCCESS") {
            
          for (var i = 0; i < components.length; i += 4) {
              var div = components[i];
              var image = components[i + 1];
              var div2 = components[i + 2];
              var div3 = components[i + 3];
              var div2Body = div2.get("v.body");
              div2Body.push(div3);
              div2.set("v.body", div2Body);
              var divBody = div.get("v.body");
              divBody.push(image);
              divBody.push(div2);
              div.set("v.body", divBody);
              div1Body.push(div);
          }
          div1.set("v.body", div1Body);
            
        } else if (cmp.isValid() && status === "ERROR") {
          self.showNotificationEvt('error', message, null);
        } else if (cmp.isValid() && status === "INCOMPLETE") {
          errorMessage = "No response from server or client is offline";
          self.showNotificationEvt('error', errorMessage, null);
        }
      }
    );
  },
  createRadioPicklist: function(cmp, answer, uiCmps) {

    for (var i = 0; i < answer.length; i++) {

      var attrs = {
        "class": "slds-p-vertical_xx-small",
        "answers": answer[i].Name || answer[i],
        "QuesId": cmp.get("v.QuestionTemplate.Id")

      };

      var uiCmp = [
        "c:RadioOptions",
        attrs
      ];
      uiCmps.push(uiCmp);
    }

    this.createUiCmps(cmp, uiCmps);
  },
  createText: function(cmp, uiCmps) {
    var attrs = {
      "class": "slds-input",
      "label": ""
    };
    var uiCmp = [
      "ui:inputText",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createNumber: function(cmp, uiCmps) {
    var attrs = {
      "class": "slds-input",
      "label": ""
    };
    var uiCmp = [
      "ui:inputNumber",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createTextarea: function(cmp, uiCmps) {

    var attrs = {
      "class": "slds-input",
      "label": ""
    };
    var uiCmp = [
      "ui:inputTextArea",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createDate: function(cmp, uiCmps) {

    var attrs = {
      "class": "slds-input slds_width",
      "label": "Date :",
      "displayDatePicker": true
    };
    var uiCmp = [
      "ui:inputDate",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createEmail: function(cmp, uiCmps) {
    var attrs = {
      "class": "slds-input",
      "label": "Email  :"
    };

    var uiCmp = [
      "ui:inputEmail",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createPhoneNumber: function(cmp, uiCmps) {
    var attrs = {
      "class": "slds-input",
      "label": "Phone  :"
    };
    var uiCmp = [
      "ui:inputPhone",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createDropdownPicklist: function(cmp, answer, uiCmps) {

    var opts = [];

    for (var i = 0; i < answer.length; i++) {
        var option = {};
        option["optionText"] = answer[i].Name || answer[i];
        option["optionValue"] = answer[i].Name || answer[i];
        option["type"] = "answerViewer";
        opts.push(option);      
    }

    var attrs = {
      "showIcon": true,
      "hideLabel": false,
      "attributes": opts,
      "sourceDerivenCmp" : {'type' : 'AnswerViewer'}
    };
    var uiCmp = [
        "c:CtrlLinkMenu",
        attrs
    ];
    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createButton: function(cmp, answer, uiCmps) {

    var HTMLAttributes = {
      "class": "slds-button slds-button--neutral"
    };

    for (var i = 0; i < answer.length; i++) {

      var tag = {
        "tag": "button",
        "body": answer[i].Name || answer[i],
        HTMLAttributes
      };

      var uiCmp = [
        "aura:html",
        tag
      ];
      uiCmps.push(uiCmp);
    }

    this.createUiCmps(cmp, uiCmps);
  },
  createMultiselectPicklist: function(cmp, answer, uiCmps) {

    for (var i = 0; i < answer.length; i++) {
      var attrs = {
        "class": "slds-p-vertical_xx-small",
        "label": answer[i].Name || answer[i],
        "labelClass": "slds-p-vertical_xx-small",
        "text": answer[i].Name || answer[i]
      };

      var uiCmp = [
        "ui:inputCheckbox",
        attrs
      ];
      uiCmps.push(uiCmp);
    }
    this.createUiCmps(cmp, uiCmps);
  },
  createList: function(cmp, answer, uiCmps) {
    var HTMLAttributes = {
      "class": "slds-p-vertical_xx-small"
    };

    for (var i = 0; i < answer.length; i++) {
      var tag = {
        "tag": "div",
        "body": answer[i].Name || answer[i],
        HTMLAttributes
      };

      var uiCmp = [
        "aura:html",
        tag
      ];
      uiCmps.push(uiCmp);
    }

    this.createUiCmps(cmp, uiCmps);
  },
  createCase: function(cmp, uiCmps) {

    var attrs = {
      "class": "te",
      "labelClass": "absolute",
      "change": cmp.getReference("c.hasCheck")
    };

    var uiCmp = [
      "ui:inputCheckbox",
      attrs
    ];
    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createSignature: function(cmp, uiCmps) {

    var attrs = {
      "height": 100
    };

    var uiCmp = [
      "c:SignatureCmp",
      attrs
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);

  },
  createFileQuestion: function(cmp, uiCmps) {

    var HTMLAttributes = {
      "class": "slds-button slds-button--neutral"
    };

    var tag = {
      "tag": "button",
      "body": "Choose File",
      HTMLAttributes
    };

    var uiCmp = [
      "aura:html",
      tag
    ];

    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createImage: function(cmp, imageSrc, answer, uiCmps) {
    var source;
    for (var i = 0; i < imageSrc.length; i++) {
      if (imageSrc[i] != null) {
        source = cmp.get("v.imagePrefix") + imageSrc[i];
      } else {
        source = $A.get('$Resource.ExAM__NoImage');        
      }
      var HTMLAttributes = {
        "id": 'kk',
        "class": 'image-container tooltip-container'
      };
      var tag = {
        "tag": "div",
        HTMLAttributes
      };
      var uiCmp = [
        "aura:html",
        tag
      ];
      uiCmps.push(uiCmp);

      var HTMLAttributes = {
        "src": source,
        "class": "img"
      };
      var tag = {
        "tag": "img",
        HTMLAttributes
      };
      var uiCmp = [
        "aura:html",
        tag
      ];
      uiCmps.push(uiCmp);
          
           // NEW ADD
          var HTMLAttributes = {
          "id": 'kk',
          "class": 'slds-popover slds-popover--tooltip slds-nubbin--bottom-left'
      		};
        var tag = {
            "tag": "div",
            HTMLAttributes
        };
            var uiCmp = [
            "aura:html",
            tag
            ];
            uiCmps.push(uiCmp);
            // NEW ADD
            
            var HTMLAttributes = {
            "id": 'kk',
            "class": 'proper-case slds-popover__body'
        	};
        	var tag = {
                "tag": "div",
                "body": answer[i].Name ? answer[i].Name : answer[i] ? answer[i] : '',
                HTMLAttributes
        	};
            var uiCmp = [
            "aura:html",
            tag
            ];
            uiCmps.push(uiCmp);
    }
                
    this.craeteUiCmpsByImage(cmp, uiCmps);
  },
  createHorizontalRadioPicklist: function(cmp, answer, uiCmps) {

    for (var i = 0; i < answer.length; i++) {
      var attrs = {
        "class": "horizontal",
        "answers": answer[i].Name || answer[i],
        "QuesId": cmp.get("v.QuestionTemplate.Id")

      };

      var uiCmp = [
        "c:RadioOptions",
        attrs
      ];

      uiCmps.push(uiCmp);
    }
    this.createUiCmps(cmp, uiCmps);
  },
  createCheckbox : function(cmp, uiCmps){
    var attrs = {
      "class": "te",
      "labelClass": "absolute"
    };

    var uiCmp = [
      "ui:inputCheckbox",
      attrs
    ];
    uiCmps.push(uiCmp);
    this.createUiCmps(cmp, uiCmps);
  },
  createFileUpload : function(cmp, uiCmps){
      var HTMLAttributes = {
          "type": 'file',
          "class": 'slds-button slds-button--neutral'
      };
      
      var tag = {
          "tag": "button",
          "body": "Choose File",
          HTMLAttributes
      };
          
      var uiCmp = [
          "aura:html",
          tag
      ];
      uiCmps.push(uiCmp);
      this.createUiCmps(cmp, uiCmps);   
  },
  showNotificationEvt: function(status, message, time) {
    var showNotificationEvent = $A.get("e.c:notificationEvt");
    showNotificationEvent.setParams({
      "action": status,
      "message": message
    });
    showNotificationEvent.fire();
  }

})