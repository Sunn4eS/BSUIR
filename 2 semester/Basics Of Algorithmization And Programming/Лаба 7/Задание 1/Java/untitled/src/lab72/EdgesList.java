package lab72;

class Edge {
    int value;
    Edge next;
    Edge (int value) {
        this.value = value;
        this.next = null;
    }
}
public class EdgesList {
    Edge head;
    EdgesList () {
        this.head = null;
    }
    boolean add(int value) {
        boolean isAdded;
        if (this.head == null) {
            this.head = new Edge(value);
            isAdded = true;
        } else {
            Edge edge = this.head;
            while (edge.next != null && edge.value != value) {
                edge = edge.next;
            }
            if (edge.value != value) {
                edge.next = new Edge(value);
                isAdded = true;
            } else {isAdded = false;};
        }
        return isAdded;
    }
    void delete(int value) {
        if (this.head.value == value) {
            this.head = this.head.next;
        } else {
            Edge edge = this.head;
            while (edge.next.value != value) {
                edge = edge.next;
            }
            edge.next = edge.next.next;
        }
    }
}
