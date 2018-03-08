({
    afterRender: function (cmp, helper) {
        this.superAfterRender();
        var canvas = cmp.find("can").getElement();
        var ctx = canvas.getContext("2d");
        cmp.set("v.canvas",canvas);
        cmp.set("v.ctx",ctx);
        
        
        if(cmp.isValid()){
            canvas.addEventListener("mousemove", function (e) {
                helper.findxy(cmp,'move', e)
            }, false);
            canvas.addEventListener("mousedown", function (e) {
                helper.findxy(cmp,'down', e)
            }, false);
            canvas.addEventListener("mouseup", function (e) {
                helper.findxy(cmp,'up', e)
            }, false);
            canvas.addEventListener("mouseout", function (e) {
                helper.findxy(cmp,'out', e)
            }, false);
        }  
        
    },
})