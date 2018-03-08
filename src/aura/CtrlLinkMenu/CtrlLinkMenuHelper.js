({
  windowClick: null,

  toggleDropdown: function(cmp, event) {
    var closeDrop = $A.get("e.c:closeDropDownEvt");
    closeDrop.setParams({
      "index": cmp.get("v.itemIndex"),
      "sourceDerivenCmp" : cmp.get("v.sourceDerivenCmp").type
    });
    closeDrop.fire();

    var dropdown = cmp.find('dropdown');
    $A.util.toggleClass(dropdown, 'slds-is-open');
    event.stopPropagation();
  },
  closeDropdown: function(cmp, event) {
    var dropdown = cmp.find('dropdown');
    $A.util.removeClass(dropdown, 'slds-is-open');
  },
  fireEventHelper: function(cmp, event) {
      var cmpEvent = cmp.getEvent("ctrlLinkMenuEvt");
      var value = event.currentTarget.getAttribute("data-optionValue");
      var label = event.currentTarget.getAttribute("data-optionText");
      var action = event.currentTarget.getAttribute("data-optionValue");
      var index = cmp.get("v.itemIndex");
      var sourceDerivenCmp = cmp.get("v.sourceDerivenCmp");
      
      if(sourceDerivenCmp){
          var type = sourceDerivenCmp.type;
          var lableName = sourceDerivenCmp.label;
      }
      
      cmpEvent.setParams({
          "action": action,
          "itemIndex": index,
          "value": value,
          "label": label,
          "type" : type,
          "name" : lableName,
          "uniqueName" : event.currentTarget.getAttribute("data-unique")
      });
      cmpEvent.fire();
  }
})