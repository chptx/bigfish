<#if (shoppingCartSize > 0)>
<div class="${request.getAttribute("attributeClass")!}">
  ${screens.render("component://osafe/widget/EcommerceDivScreens.xml#${summaryScreen!}OrderItemsSummaryDivSequence")}
</div>  
</#if>
