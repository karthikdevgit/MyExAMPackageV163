({
    findxy : function(cmp,res, e) {
        
        var flag = cmp.get("v.flag");
        var dot_flag = cmp.get("v.dot_flag");
        var prevX = cmp.get("v.prevX");
        var currX = cmp.get("v.currX");
        var prevY = cmp.get("v.prevY");
        var currY = cmp.get("v.currY");
        var ctx = cmp.get("v.ctx");
        var canvas = cmp.get("v.canvas"); 
        
        if (res === 'down') {
            
            
            prevX =  e.clientX ;
            prevY =  e.clientY;
            currX = e.clientX - canvas.getBoundingClientRect().left;
            currY = e.clientY - canvas.getBoundingClientRect().top;
            
            flag = true;
            dot_flag = true;
            
            
            cmp.set("v.flag",flag);
            cmp.set("v.dot_flag",dot_flag);
            cmp.set("v.prevX",prevX);
            cmp.set("v.prevY",prevY);
            cmp.set("v.currX",currX);
            cmp.set("v.currY",currY);
            
            if (dot_flag) {
                ctx.beginPath();
                ctx.fillStyle = 'black';
                ctx.fillRect(currX, currY, 2, 2);
                ctx.closePath();
                dot_flag = false;
                cmp.set("v.dot_flag",dot_flag);
            }
        }
        if (res === 'up' || res === "out") {
            
            cmp.set("v.flag",false);
        }
        if (res === 'move') {
            
            if (cmp.get("v.flag")) {
                
                
                prevX = currX;
                prevY = currY;
                currX = e.clientX - canvas.getBoundingClientRect().left;
                currY = e.clientY - canvas.getBoundingClientRect().top;
                this.draw(cmp,ctx,prevX,prevY,currX,currY);
                cmp.set("v.prevX",prevX);
                cmp.set("v.prevY",prevY);
                cmp.set("v.currX",currX);
                cmp.set("v.currY",currY);
                cmp.set("v.hasRefresh",true);
            }
        }
    },
    // draw the signature 
    draw : function(cmp,ctx,prevX,prevY,currX,currY){
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = 'black';
        ctx.lineWidth = 2;
        ctx.stroke();
        ctx.closePath();
    },
    // clear the signature in canvas
    clearsign : function(cmp,event){
        var canvas = cmp.get("v.canvas");
        var ctx = cmp.get("v.ctx");
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        cmp.set("v.hasRefresh",false);
    }
})