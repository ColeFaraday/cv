{% extends "section.md" %}

{% block body %}
Slides for my presentations are linked below under a CC-BY license.

{% raw %}
<div class="publications">

{% bibliography -f {{ site.scholar.secondarybib }} %}

</div>
{% endraw %}

{% endblock body %}
