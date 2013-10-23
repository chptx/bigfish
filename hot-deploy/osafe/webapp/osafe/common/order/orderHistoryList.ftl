<div class="${request.getAttribute("attributeClass")!}">
 <#if orderHeaderList?has_content>
    <div class="boxList orderList">
        <#list orderHeaderList as orderHeader>
	      ${setRequestAttribute("orderHeader", orderHeader)}
	      ${screens.render("component://osafe/widget/EcommerceDivScreens.xml#orderHistoryOrderDetailsDivSequence")}
	    </#list>
	</div>
 <#else>
   <div class="displayBox">
    <h3>${uiLabelMap.OrderNoOrderFoundInfo}</h3>
   </div>
 </#if>
</div>

