## Publications

<!-- [<a href="https://scholar.google.com/citations?user={{ scholar_id }}">Google Scholar</a>: {{ scholar_stats.citations }} citations and an h-index of {{ scholar_stats.h_index}}] <br> -->


{% raw %}
See also: <a href="https://inspirehep.net/authors/{{ site.data.socials.inspirehep_id }}">Inspire HEP</a>, <a href="https://scholar.google.com/citations?user={{ site.data.socials.scholar_userid }}">Google Scholar</a>, and <a href="https://orcid.org/{{ site.data.socials.orcid_id }}"> ORCID </a>.

{% assign pub_page = site.pages | where: "permalink", "/publications/" | first %}
<div class="publications">

{%- for section in pub_page.sections %}
  <h3 id="{{section.text}}">{{section.text}}</h3>

    {%- comment -%}  Count bibliography in actual section and year {%- endcomment -%}
    {%- capture citecount -%}
    {%- bibliography_count -f {{site.scholar.bibliography}} -q {{section.bibquery}} -%}
    {%- endcapture -%}

    {%- comment -%} If exist bibliography in actual section and year, print {%- endcomment -%}
    {%- if citecount !="0" %}

      {% bibliography -f {{site.scholar.bibliography}} -q {{section.bibquery}} %}

    {%- endif -%}

{%- endfor %}


</div>


{% endraw %}