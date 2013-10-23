<li class="${request.getAttribute("attributeClass")!}">
  <#if pdpInternalName?has_content>
    <div>
      <label>${uiLabelMap.PDPInternalNameLabel}</label>
      <span>${pdpInternalName!""}</span>
    </div>
  </#if>
</li>
