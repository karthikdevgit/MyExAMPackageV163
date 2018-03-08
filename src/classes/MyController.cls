public with sharing class MyController {

    public String accountId { get; set; }
    @TestVisible public List<SelectOption> accountOptions {
        get {
            Node root = new Node();
            List<Account> nextPass = [select Id, ParentId, Name from Account order by Name LIMIT 100];
            System.debug('----- '+nextPass );
            while (!nextPass.isEmpty()) {
                List<Account> currentPass = nextPass;
                nextPass = new List<Account>();
                for (Account account : currentPass) {
                    if (!root.add(account)) {
                        nextPass.add(account);
                    }
                }
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            root.buildOptions(options);
            return options;
        } private set;
    }


    private class Node {
        private Account account;
        private List<Node> children = new List<Node>();
        private Integer depth = -1;
        public Node() {
        }
        private Node(Account account, Integer depth) {
            this.account = account;
            this.depth = depth;
        }
        public Boolean add(Account candidate) {
            return add(candidate, 0);
        }
        private Boolean add(Account candidate, Integer depth) {
            if ((isRoot() && candidate.ParentId == null) || (!isRoot() && candidate.ParentId == account.Id)) {
                children.add(new Node(candidate, depth));
                return true;
            } else {
                for (Node child : children) {
                    if (child.add(candidate, depth + 1)) {
                        return true;
                    }
                }
            }
            return false;
        }
        private Boolean isRoot() {
            return account == null;
        }
        public void buildOptions(List<SelectOption> options) {
            if (account != null) {
                options.add(createSelectOption());
            }
            for (Node child : children) {
                child.buildOptions(options);
            }
        }
        private SelectOption createSelectOption() {
            String label = '';
            for (Integer i = 0; i < depth; i++) {
                label += '    ';
            }
            label += account.Name;
            SelectOption option = new SelectOption(account.Id, label);
            option.setEscapeItem(false);
            return option;
        }
    } 
}