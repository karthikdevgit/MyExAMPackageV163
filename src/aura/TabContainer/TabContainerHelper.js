({
    handleSettingSelectedTab : function(cmp, activeTab) {
        var cmpnentChildList = cmp.find("list").find({
            instancesOf: "c:TabComponent"
        })
        //finding the child components and setting the active status
        
        for (var i = 0; i < cmpnentChildList.length; i++) {
            var outputCmpArr = cmpnentChildList[i];
            outputCmpArr.set("v.active", outputCmpArr.get("v.index") === activeTab);
            
        }
    }
})