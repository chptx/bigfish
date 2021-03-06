<div class="${request.getAttribute("attributeClass")!}">
 <#if (orderItems?has_content && orderItems.size() > 0)>
	    <#assign rowClass = "1">
		<#assign idx=1?number/>
		<#assign CURRENCY_UOM_DEFAULT = Static["com.osafe.util.Util"].getProductStoreParm(request,"CURRENCY_UOM_DEFAULT")!""/>
		<#assign currencyUom = CURRENCY_UOM_DEFAULT!currencyUomId />
		<#assign rowClass = "1">
        <div class="boxList cartList">
 	    <#list orderItems as orderItem>
		    ${setRequestAttribute("orderHeader", orderHeader)}
		    ${setRequestAttribute("orderItem", orderItem)}
		    ${setRequestAttribute("localOrderReadHelper", localOrderReadHelper)}
		    ${setRequestAttribute("idx", idx)}
		    ${setRequestAttribute("rowClass", rowClass)}
	        ${screens.render("component://osafe/widget/EcommerceDivScreens.xml#orderDetailOrderItemsDivSequence")}
	        <#if rowClass == "2">
	            <#assign rowClass = "1">
	        <#else>
	            <#assign rowClass = "2">
	        </#if>
	        <#assign idx= idx + 1/>
	    </#list>
	    </div>
  </#if>
</div>

