<?php
class TableBuilder
{
    private $headers = [];
    private $rows = [];
    private string $tableClass = '';
    private string $theadClass = '';
    private string $trClass = '';
    private string $tdClass = '';

    public function setClasses(string $table = '', string $thead = '', string $tr = '', string $td = ''): self
    {
        $this->tableClass = $table;
        $this->theadClass = $thead;
        $this->trClass = $tr;
        $this->tdClass = $td;
        return $this;
    }

    public function setHeaders(array $headers): self
    {
        $this->headers = $headers;
        return $this;
    }

    public function addRow(array $rows): self
    {
        $this->rows[] = $rows;
        return $this;
    }

    public function createTable(): string
    {
        $html = "<table class =\'{$this->tableClass}\">\n";
        if (!empty($this->headers)) {
            $html .= "  <thead class=\"{$this->theadClass}\">\n    <tr class=\"{$this->trClass}\">\n";
            foreach ($this->headers as $header) {
                $html .= "      <th class=\"{$this->tdClass}\">" . $header . "</th>\n";
            }
            $html .= "    </tr>\n  </thead>\n";
        }
        $html .= "  <tbody>\n";
        foreach ($this->rows as $row) {
            $html .= "    <tr class=\"{$this->trClass}\">\n";
            foreach ($row as $cell) {
                $html .= "      <td class=\"{$this->tdClass}\">" . $cell . "</td>\n";

            }
            $html .= "    </tr>\n";
        }
        return $html;
    }
}
$builder = new TableBuilder();

echo $builder
    ->setClasses('table', 'thead-dark', 'tr-style', 'td-style')
    ->setHeaders(['Имя', 'Возраст', 'Город'])
    ->addRow(['Анна', 23, 'Минск'])
    ->addRow(['Иван', 30, 'Гродно'])
    ->addRow(['Мария', 27, 'Брест'])
    ->createTable();
