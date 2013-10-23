<script type="text/javascript">
    function submitCheckoutForm(form, mode, value) 
    {
        if (mode == "DN") {
            // done action; checkout
            form.action="<@ofbizUrl>${doneAction!""}</@ofbizUrl>";
            form.submit();
        } 
    }

</script>
