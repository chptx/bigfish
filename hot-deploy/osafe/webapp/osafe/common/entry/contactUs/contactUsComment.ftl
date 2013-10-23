<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
      <label for="content"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.CommentCaption}</label>
      <textarea name="content" id="js_content" class="content" cols="50" rows="5">${parameters.content!""}</textarea>
      <input type="hidden" name="content_MANDATORY" value="${mandatory}"/>
      <@fieldErrors fieldName="content"/>
      <div class="entry counter">
        <label for="content">&nbsp;</label>
        <span class="js_textCounter textCounter" id="js_textCounter"></span>
      </div>
</div>