{% if name.lower() != "none" %}
## {{ name }}
{% endif %}
{% if legend %}
{{ legend }}

{% endif %}
{% block body %}
{{ data }}

{% endblock body %}
