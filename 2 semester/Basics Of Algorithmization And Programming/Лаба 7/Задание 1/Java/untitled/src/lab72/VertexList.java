package lab72;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

class Vertex {
    EdgesList edges;
    int value;
    Vertex next;

    Vertex (int newValue) {
        this.value = newValue;
        this.edges = new EdgesList();
        this.next = null;
    }
    boolean isEdgeWith(int value) {
        Edge edge = edges.head;
        while (edge != null && edge.value != value) {
            edge = edge.next;
        }
        return edge != null;
    }
}
public class VertexList {
    Vertex head;
    int count;

    VertexList () {
        this.head = null;
        this.count = 0;
    }

    boolean addVertex(int value) {
        boolean isAdded;
        if (this.head == null) {
            this.head = new Vertex(value);
            count++;
            isAdded = true;
        } else {
            Vertex vertex = this.head;
            while (vertex.next != null && vertex.value != value) {
                vertex = vertex.next;
            }
            if (vertex.value != value) {
                vertex.next = new Vertex(value);
                isAdded = true;
                count++;
            } else {isAdded = false;};
        }
        return isAdded;
    }

    boolean containce(int value) {
        Vertex vertex = this.head;
        while (vertex != null && vertex.value != value) {
            vertex = vertex.next;
        }
        return vertex != null;
    }

    boolean addEdge(int startVertex, int endVertex) {
        boolean isAdded = false;
        Vertex vertex = this.head;
        if (vertex != null && containce(startVertex) && containce(endVertex) && startVertex != endVertex)  {
            while (vertex.value != startVertex && vertex.value != endVertex)
                vertex = vertex.next;
            vertex.edges.add(vertex.value == startVertex ? endVertex : startVertex);
            vertex = vertex.next;
            while (vertex.value != startVertex && vertex.value != endVertex)
                vertex = vertex.next;
            vertex.edges.add(vertex.value == startVertex ? endVertex : startVertex);
            isAdded = true;
        }
        return isAdded;
    }

    private void deleteEdges(Vertex vertex) {
        Edge edge = vertex.edges.head;
        while (edge != null) {
            Vertex head = this.head;
            while (head.value != edge.value) {
                head = head.next;
            }
            head.edges.delete(vertex.value);

            edge = edge.next;
        }
    }
    boolean deleteVertex(int value) {
        boolean isDeleted = false;
        if (this.count != 0 && containce(value)) {
            isDeleted = true;
            count--;
            if (this.head.value == value) {
                deleteEdges(this.head);
                this.head = this.head.next;
            } else {
                Vertex vertex = this.head;
                while (vertex.next.value != value) {
                    vertex = vertex.next;
                }
                deleteEdges(vertex.next);
                vertex.next = vertex.next.next;
            }
        }
        return isDeleted;
    }
    boolean deleteEdge(int startVert, int endVert) {
        boolean isDeleted = false;
        if (containce(startVert) && containce(endVert)) {
            isDeleted = true;
            Vertex vertex = this.head;

            while (vertex.value != startVert && vertex.value != endVert)
                vertex = vertex.next;
            vertex.edges.delete(vertex.value == startVert ? endVert : startVert);

            vertex = vertex.next;
            while (vertex.value != startVert && vertex.value != endVert)
                vertex = vertex.next;
            vertex.edges.delete(vertex.value == startVert ? endVert : startVert);
        }
        return isDeleted;
    }

    void print() {
        Vertex vertex = this.head;
        while (vertex != null) {
            System.out.print("Вершина: " + vertex.value);
            System.out.print("  -->  ");
            Edge edge = vertex.edges.head;
            while (edge != null) {
                System.out.print(edge.value + " ");
                edge = edge.next;
            }
            System.out.println();

            vertex = vertex.next;
        }
    }

    void printMatrix() {
        Vertex vertex = this.head;
        StringBuilder line = new StringBuilder("   ");
        for (int i = 0; i < this.count; i++){
            line.append(String.format("%-3d", vertex.value));
            vertex = vertex.next;
        }
        System.out.println(line);
        Vertex mainVertex = this.head;
        for (int i = 1; i <= this.count; i++){
            line = new StringBuilder(String.format("%-3d", mainVertex.value));

            vertex = this.head;
            for (int j = 1; j <= this.count; j++){
                int isEdgeWithVert = mainVertex.isEdgeWith(vertex.value) ? 1 : 0;
                line.append(String.format("%-3d", isEdgeWithVert));
                vertex = vertex.next;
            }
            System.out.println(line);
            mainVertex = mainVertex.next;
        }
    }
    private Vertex[] getArray() {
        Vertex vertex = this.head;
        Vertex[] array = new Vertex[this.count];
        int i = 0;
        while (vertex != null) {
            array[i++] = vertex;
            vertex = vertex.next;
        }
        return array;
    }
    Vertex getByValue(int value) {
        Vertex vertex = this.head;
        while (vertex != null && vertex.value != value) {
            vertex = vertex.next;
        }
        return vertex;
    }
    void findWay(int startVal) {
        final int INF = 2000000000;
        HashMap<Vertex, Integer> wayMap = new HashMap<>();
        Vertex[] vertexArray = getArray();
        for (int i = 0; i < this.count; i++) {
            wayMap.put(vertexArray[i], vertexArray[i].value == startVal ? 0 : INF);
        }
        for (int i = 0; i < this.count; i++) {
            for (Vertex vertex : vertexArray) {
                Edge edge = vertex.edges.head;
                while (edge != null) {
                    Vertex currVert = getByValue(edge.value);
                    if (wayMap.get(vertex) + 1 < wayMap.get(currVert))
                        wayMap.put(currVert, wayMap.get(vertex) + 1);

                    edge = edge.next;
                }
            }
        }
        Vertex startVert = getByValue(startVal);
        for (Vertex key : wayMap.keySet()) {
            if (key != startVert) {
                String wayLen = wayMap.get(key) == INF ? "нет" : wayMap.get(key).toString();
                System.out.println("Путь из " + startVert.value + " в " + key.value + " --> " + wayLen);
            }
        }
    }
}